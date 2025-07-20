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

import Foundation
public enum ShapefileError : Error {
  case inconsistentRecordCount(Int, Int)
}
public struct Shapefile {
  public var dbf: DBF
  public var shp: ShapeFileGeometry

  public init(url: URL) throws {
    let dbfURL = url.appendingPathExtension("dbf")
    let shpURL = url.appendingPathExtension("shp")
    try self.init(dbfURL: dbfURL, shpURL: shpURL)
  }

  init(dbfURL: URL, shpURL: URL) throws
  {
    let dbfData = try Data(contentsOf: dbfURL)
    self.dbf = try DBF(parsing: dbfData)

    let geoData = try Data(contentsOf: shpURL)
    self.shp = try ShapeFileGeometry(parsing: geoData)
    guard dbf.records.count == shp.records.count else {
      throw ShapefileError.inconsistentRecordCount(dbf.records.count, shp.records.count)
    }
  }

  var count : Int {
    get {
      return shp.records.count
    }
  }

  subscript (index: Int) -> (Shape, [String : DBF.RecordValue]) {
    get {
      (shp.records[index], dbf.row(index))
    }
  }
}
