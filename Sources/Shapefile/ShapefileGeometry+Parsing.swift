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

extension NullShape {
  convenience init(parsing input: inout ParserSpan) throws {
    self.init()
  }
}

extension Point {
  convenience init(parsing input: inout ParserSpan) throws {
    let x = try Double(parsingLittleEndian: &input)
    let y = try Double(parsingLittleEndian: &input)
    let p = Point2d(x: x, y: y)
    self.init(point: p)
  }
}

extension MultiPoint {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    self.init(bounds: box)

    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      self.points += [p]
    }
  }
}

extension Polyline {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    self.init(bounds: box)

    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      self.parts += [part]
    }

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      self.points += [p]
    }
  }
}

extension Polygon {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    self.init(bounds: box)

    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      self.parts += [part]
    }

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      self.points += [p]
    }
  }
}

extension PointM {
  convenience init(parsing input: inout ParserSpan) throws {
    let x = try Double(parsingLittleEndian: &input)
    let y = try Double(parsingLittleEndian: &input)
    let m = try Double(parsingLittleEndian: &input)
    let p = Point2dm(x: x, y: y, m: m)
    self.init(point: p)
  }
}

extension MultiPointM {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    var tmpPoints: [Point2d]  = []
    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }
    let range = try MRange(parsing: &input)

    self.init(bounds: box, measurmentRange: range)

    var tmpMeasurments: [Double] = []
    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    for (p, m) in zip(tmpPoints, tmpMeasurments) {
      let pm = Point2dm(x: p.x, y: p.y, m: m)
      self.points += [pm]
    }
  }
}

extension PolylineM {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)


    var tmpParts : [Int] = []

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      tmpParts += [part]
    }

    var tmpPoints: [Point2d] = []

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let range = try MRange(parsing: &input)

    self.init(bounds: box, measurmentRange: range)

    var tmpMeasurments: [Double] = []

    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    for (p, m) in zip(tmpPoints, tmpMeasurments) {
      let pm = Point2dm(x: p.x, y: p.y, m: m)
      self.points += [pm]
    }

    self.parts = tmpParts
  }
}

extension PolygonM {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)


    var tmpParts : [Int] = []

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      tmpParts += [part]
    }

    var tmpPoints: [Point2d] = []

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let range = try MRange(parsing: &input)

    self.init(bounds: box, measurmentRange: range)

    var tmpMeasurments: [Double] = []

    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    for (p, m) in zip(tmpPoints, tmpMeasurments) {
      let pm = Point2dm(x: p.x, y: p.y, m: m)
      self.points += [pm]
    }

    self.parts = tmpParts
  }
}

extension PointZ {
  convenience init(parsing input: inout ParserSpan) throws {
    let x = try Double(parsingLittleEndian: &input)
    let y = try Double(parsingLittleEndian: &input)
    let z = try Double(parsingLittleEndian: &input)
    let m = try Double(parsingLittleEndian: &input)
    let p = Point3d(x: x, y: y, z: z, m: m)
    self.init(point: p)
  }
}

extension MultiPointZ {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    var tmpPoints: [Point2d]  = []
    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let zRange = try ZRange(parsing: &input)

    var tmpZ: [Double] = []
    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpZ += [m]
    }

    let mRange = try MRange(parsing: &input)
    self.init(bounds: box, zRange: zRange, measurmentRange: mRange)

    var tmpMeasurments: [Double] = []
    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }


    for (p, (z, m)) in zip(tmpPoints, zip(tmpZ, tmpMeasurments)) {
      let pm = Point3d(x: p.x, y: p.y, z: z, m: m)
      self.points += [pm]
    }
  }
}

extension PolylineZ {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)


    var tmpParts : [Int] = []

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      tmpParts += [part]
    }

    var tmpPoints: [Point2d] = []

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let zRange = try ZRange(parsing: &input)

    var tmpZ: [Double] = []

    for _ in 0..<numPoints {
      let z = try Double(parsingLittleEndian: &input)
      tmpZ += [z]
    }

    let mRange = try MRange(parsing: &input)


    var tmpMeasurments: [Double] = []

    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    self.init(bounds: box, zRange: zRange, measurmentRange: mRange)

    for (p, (z, m)) in zip(tmpPoints, zip(tmpZ, tmpMeasurments)) {
      let pm = Point3d(x: p.x, y: p.y, z: z, m: m)
      self.points += [pm]
    }

    self.parts = tmpParts
  }
}

extension PolygonZ {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)


    var tmpParts : [Int] = []

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      tmpParts += [part]
    }

    var tmpPoints: [Point2d] = []

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let zRange = try ZRange(parsing: &input)

    var tmpZ: [Double] = []

    for _ in 0..<numPoints {
      let z = try Double(parsingLittleEndian: &input)
      tmpZ += [z]
    }

    let mRange = try MRange(parsing: &input)


    var tmpMeasurments: [Double] = []

    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    self.init(bounds: box, zRange: zRange, measurmentRange: mRange)

    for (p, (z, m)) in zip(tmpPoints, zip(tmpZ, tmpMeasurments)) {
      let pm = Point3d(x: p.x, y: p.y, z: z, m: m)
      self.points += [pm]
    }
    self.parts = tmpParts
  }
}

extension Multipatch {
  convenience init(parsing input: inout ParserSpan) throws {
    let box = try BoundingBox(parsing: &input)
    let numParts = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
    let numPoints = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)


    var tmpParts : [Int] = []

    for _ in 0..<numParts {
      let part = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)
      guard part < numPoints else {
        throw ShapeFileError.badPartIndex
      }
      tmpParts += [part]
    }

    var tmpPartTypes : [PartType] = []
    for _ in 0..<numParts {
      let part = try PartType(parsing: &input, storedAsLittleEndian: UInt32.self)
      tmpPartTypes += [part]
    }

    var tmpPoints: [Point2d] = []

    for _ in 0..<numPoints {
      let x = try Double(parsingLittleEndian: &input)
      let y = try Double(parsingLittleEndian: &input)
      let p = Point2d(x: x, y: y)
      tmpPoints += [p]
    }

    let zRange = try ZRange(parsing: &input)

    var tmpZ: [Double] = []

    for _ in 0..<numPoints {
      let z = try Double(parsingLittleEndian: &input)
      tmpZ += [z]
    }

    let mRange = try MRange(parsing: &input)

    var tmpMeasurments: [Double] = []

    for _ in 0..<numPoints {
      let m = try Double(parsingLittleEndian: &input)
      tmpMeasurments += [m]
    }

    self.init(bounds: box, zRange: zRange, measurmentRange: mRange)

    for (p, (z, m)) in zip(tmpPoints, zip(tmpZ, tmpMeasurments)) {
      let pm = Point3d(x: p.x, y: p.y, z: z, m: m)
      self.points += [pm]
    }

    self.parts = tmpParts
    self.partTypes = tmpPartTypes
  }
}

extension BoundingBox {
  init(parsing input: inout ParserSpan) throws {
    self.minX = try Double(parsingLittleEndian: &input)
    self.minY = try Double(parsingLittleEndian: &input)
    self.maxX = try Double(parsingLittleEndian: &input)
    self.maxY = try Double(parsingLittleEndian: &input)
  }
}
extension ZRange {
  init(parsing input: inout ParserSpan) throws {
    self.minZ = try Double(parsingLittleEndian: &input)
    self.maxZ = try Double(parsingLittleEndian: &input)
  }
}
extension MRange {
  init(parsing input: inout ParserSpan) throws {
    self.minM = try Double(parsingLittleEndian: &input)
    self.maxM = try Double(parsingLittleEndian: &input)
  }
}

extension ShapeFileHeader {
  init(parsing input: inout ParserSpan) throws {
    let magic = try Int(parsing: &input, storedAsBigEndian: UInt32.self)
    guard magic == 0x0000270a else {
      throw ShapeFileError.magicError
    }

    try input.seek(toAbsoluteOffset: 24)
    self.fileLength = try Int(parsing: &input, storedAsBigEndian: UInt32.self)
    self.version = try Int(parsing: &input, storedAsLittleEndian: UInt32.self)

    self.shapeType = try ShapeType(parsing: &input, storedAsLittleEndian: UInt32.self)
    self.boundingBox = try BoundingBox(parsing: &input)
    self.zRange = try ZRange(parsing: &input)
    self.measurementRange = try MRange(parsing: &input)
  }
}

extension ShapeRecordHeader {
  init(parsing input: inout ParserSpan) throws {
    self.recordNumber = try Int(parsing: &input, storedAsBigEndian: UInt32.self)
    self.recordLength = try Int(parsing: &input, storedAsBigEndian: UInt32.self)
  }
}

extension ShapeFileGeometry : ExpressibleByParsing {
  public init(parsing input: inout ParserSpan) throws {
    header = try ShapeFileHeader(parsing: &input)

    var recordIndex = 0
    var recordWords = 0
    while input.count > 0 {
      let recordHeader = try ShapeRecordHeader(parsing: &input)
      if recordHeader.recordNumber != recordIndex + 1 {
        throw ShapeFileError.unexpectedRecordNumber
      }
      recordIndex = recordHeader.recordNumber
      recordWords += recordHeader.recordLength

      let shapeType = try ShapeType(parsing: &input, storedAsLittleEndian: UInt32.self)

      // ESRI Shapefile Technical Description (1998) p4:
      //   All the non-Null shapes in a shapefile are required to be of the same shape type.
      guard shapeType == header.shapeType || shapeType == .nullShape else {
        throw ShapeFileError.unexpectedRecordType
      }

      switch shapeType {
      case .nullShape:
        let shape = try NullShape(parsing: &input)
        self.records += [shape]
      case .point:
        let shape = try Point(parsing: &input)
        self.records += [shape]
      case .polyline:
        let shape = try Polyline(parsing: &input)
        self.records += [shape]
      case .polygon:
        let shape = try Polygon(parsing: &input)
        self.records += [shape]
      case .multipoint:
        let shape = try MultiPoint(parsing: &input)
        self.records += [shape]
      case .pointZ:
        let shape = try PointZ(parsing: &input)
        self.records += [shape]
      case .polylineZ:
        let shape = try PolylineZ(parsing: &input)
        self.records += [shape]
      case .polygonZ:
        let shape = try PolygonZ(parsing: &input)
        self.records += [shape]
      case .multipointZ:
        let shape = try MultiPointZ(parsing: &input)
        self.records += [shape]

      case .pointM:
        let shape = try PointM(parsing: &input)
        self.records += [shape]

      case .polylineM:
        let shape = try PolylineM(parsing: &input)
        self.records += [shape]

      case .polygonM:
        let shape = try PolygonM(parsing: &input)
        self.records += [shape]

      case .multipointM:
        let shape = try MultiPointM(parsing: &input)
        self.records += [shape]

      case .multipatch:
        let shape = try Multipatch(parsing: &input)
        self.records += [shape]
      }
    }
  }
}
