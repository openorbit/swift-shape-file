//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2025 Mattias Holm
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import BinaryParsing
import Foundation

extension DBF.Header {
  init(parsing input: inout ParserSpan) throws {
    self.dbfVersion = try UInt8(parsing: &input)
    let year = try 1900 + Int(UInt8(parsing: &input))
    let month = try Int(UInt8(parsing: &input))
    let day = try Int(UInt8(parsing: &input))
    var dateComp: DateComponents = DateComponents()
    dateComp.year = year
    dateComp.month = month
    dateComp.day = day
    guard let date = Calendar(identifier: .gregorian).date(from: dateComp) else {
      throw DBFError.invalidHeaderDate("\(year)-\(month)-\(day)")
    }

    self.lastUpdate = date

    self.numRecords = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    self.headerLength = try Int(parsing: &input, storedAsLittleEndian: UInt16.self)
    self.recordLength = try Int(parsing: &input, storedAsLittleEndian: UInt16.self)

    try input.seek(toRelativeOffset: 2)

    self.incompleteTransaction = try Bool(UInt8(parsing: &input) != 0)
    self.isEncrypted = try Bool(UInt8(parsing: &input) != 0)

    try input.seek(toRelativeOffset: 12)

    self.productionMDX = try Bool(UInt8(parsing: &input) != 0)

    self.languageDriver = try UInt8(parsing: &input)
    try input.seek(toRelativeOffset: 2)

    assert(input.startPosition == 32)
  }
}

extension DBF.FieldDescriptor {
  init(parsing input: inout ParserSpan) throws {
    let initialOffset = input.startPosition
    self.name = try String(parsingUTF8: &input, count: 11).trimNullAndWS()

    assert(input.startPosition == initialOffset + 11)

    let colTypeStr = try String(parsingUTF8: &input, count: 1)
    guard let colType = DBF.ColumnType(rawValue: colTypeStr.first!) else {
      throw DBFError.unsupportedColumnType(colTypeStr)
    }
    self.columnType = colType

    try input.seek(toRelativeOffset: 4)

    self.length = try Int(parsing: &input, storedAs: UInt8.self)
    guard self.length <= 0xFE else {
      throw DBFError.invalidFieldLength(self.length)
    }
    guard self.columnType != .LOGICAL || self.length == 1 else {
      throw DBFError.invalidConstrainedFieldLength(columnType, length)
    }
    guard self.columnType != .DATE || self.length == 8 else {
      throw DBFError.invalidConstrainedFieldLength(columnType, length)
    }

    self.decimalCount = try Int(parsing: &input, storedAs: UInt8.self)
    self.workAreaID = try Int(parsing: &input, storedAsLittleEndian: UInt16.self)

    try input.seek(toRelativeOffset: 1)
    try input.seek(toRelativeOffset: 10)

    self.production = try Bool(UInt8(parsing: &input) != 0)
    assert((input.startPosition - initialOffset) % 32 == 0)
  }
}

extension DBF.Record {
  init(parsing input: inout ParserSpan, fields: [DBF.FieldDescriptor]) throws {
    let recordTag = try UInt8(parsing: &input)
    guard recordTag == 0x20 || recordTag == 0x2a else {
      throw DBFError.unexpectedRecordTag(Int(recordTag))
    }

    self.deleted = recordTag == 0x2a

    for field in fields {
      let fieldStart = input.startPosition

      switch field.columnType {
      case .DATE:
        let year = try Int(String(parsingUTF8: &input, count: 4))
        let month = try Int(String(parsingUTF8: &input, count: 2))
        let day = try Int(String(parsingUTF8: &input, count: 2))
        var dateComp: DateComponents = DateComponents()

        guard let year, let month, let day else {
          throw DBFError.invalidDate("yyyy: \(year == nil), mm: \(month == nil) dd: \(day == nil)")
        }
        dateComp.year = year
        dateComp.month = month
        dateComp.day = day
        guard let date = Calendar(identifier: .gregorian).date(from: dateComp) else {
          throw DBFError.invalidDate("\(year)-\(month)-\(day)")
        }
        self.values.append(.date(date))

      case .NUMERIC:
        if field.decimalCount == 0 {
          let rawValue = try String(parsingUTF8: &input, count: field.length).trimNullAndWS()

          if let value = Int(rawValue) {
            self.values.append(.int(value))
          } else {
            self.values.append(.null)
          }
        } else {

          let rawValue = try String(parsingUTF8: &input, count: field.length).trimNullAndWS()
          if let value = Double(rawValue) {
            self.values.append(.double(value))
          } else {
            self.values.append(.null)
          }
        }
      case .STRING:
        let value = try String(parsingUTF8: &input, count: field.length).trimNullAndWS()
        self.values.append(.string(value))
      case .FLOAT:
        let rawValue = try String(parsingUTF8: &input, count: field.length).trimNullAndWS()
        if let value = Double(rawValue) {
          self.values.append(.double(value))
        } else {
          self.values.append(.null)
        }
      case .LOGICAL:
        let logicalRawValue = try String(parsingUTF8: &input, count: field.length).trimNullAndWS()
        if logicalRawValue == "Y" || logicalRawValue == "y" || logicalRawValue == "T" || logicalRawValue == "t"  {
          self.values.append(.logical(true))
        } else if logicalRawValue == "N" || logicalRawValue == "n" || logicalRawValue == "F" || logicalRawValue == "f" {
          self.values.append(.logical(false))
        } else if logicalRawValue == "?" {
          self.values.append(.null)
        } else {
          throw DBFError.invalidFieldContent(field.columnType, logicalRawValue)
        }
      case .MEMO:
        throw DBFError.unsupportedColumnType("\(field.columnType)")
      }

      assert(fieldStart + field.length == input.startPosition)
    }
    assert(self.values.count == fields.count)
  }
}


extension DBF : ExpressibleByParsing {
  public init(parsing input: inout ParserSpan) throws {
    header = try DBF.Header(parsing: &input)

    var field = 0
    var totalRecordLength = 1
    while try UInt8(parsing: &input) != 0x0D {
      try input.seek(toAbsoluteOffset: input.startPosition - 1)
      let fieldDescriptor = try FieldDescriptor(parsing: &input)

      totalRecordLength += fieldDescriptor.length

      fields.append(fieldDescriptor)
      field += 1
    }
    assert(totalRecordLength == header.recordLength)
    // Skip the rest of the header
    try input.seek(toAbsoluteOffset: header.headerLength)

    var recordIdx = 0
    var validRecords = 0
    var deletedRecords = 0
    while try UInt8(parsing: &input) != 0x1A {

      try input.seek(toAbsoluteOffset: input.startPosition - 1)
      let recordStart = input.startPosition
      if try UInt8(parsing: &input) == 0x2a {
        try input.seek(toAbsoluteOffset: input.startPosition - 1)

        try input.seek(toRelativeOffset: header.recordLength)
        assert(input.startPosition == recordStart + header.headerLength)
        deletedRecords += 1

      } else {
        try input.seek(toAbsoluteOffset: input.startPosition - 1)
        let record = try Record(parsing: &input, fields: fields)
        records.append(record)
        validRecords += 1
      }
      recordIdx += 1
    }
  }
}
