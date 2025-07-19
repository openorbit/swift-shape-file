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

public enum ShapeFileError : Error {
  case magicError
  case unexpectedRecordNumber
  case unexpectedRecordType
  case badPartIndex
}

public enum ShapeType : Int {
  case nullShape = 0
  case point = 1
  case polyline = 3
  case polygon = 5
  case multipoint = 8
  case pointZ = 11
  case polylineZ = 13
  case polygonZ = 15
  case multipointZ = 18
  case pointM = 21
  case polylineM = 23
  case polygonM = 25
  case multipointM = 28
  case multipatch = 31
}

public enum PartType : Int {
  case triangleStrip = 0
  case triangleFan = 1
  case outerRing = 2
  case innerRing = 3
  case firstRing = 4
  case ring = 5
}

public struct BoundingBox {
  public var minX: Double
  public var minY: Double
  public var maxX: Double
  public var maxY: Double
}

public struct ZRange {
  public var minZ: Double
  public var maxZ: Double
}

public struct MRange {
  public var minM: Double
  public var maxM: Double
}

public struct ShapeFileHeader {
  public var fileLength : Int
  public var version: Int
  public var shapeType: ShapeType
  public var boundingBox: BoundingBox
  public var zRange: ZRange
  public var measurementRange: MRange
}

public struct ShapeRecordHeader {
  public var recordNumber : Int
  public var recordLength: Int
}

public struct Point2d {
  public var x: Double
  public var y: Double
}
public struct Point2dm {
  public var x: Double
  public var y: Double
  public var m: Double
}

public struct Point3d {
  public var x: Double
  public var y: Double
  public var z: Double
  public var m: Double
}


public class Shape {
  public var type: ShapeType

  init(type: ShapeType) {
    self.type = type
  }
}

public class NullShape : Shape {
  init() {
    super.init(type: .nullShape)
  }
}

public class Point : Shape {
  public var point: Point2d
  init(point: Point2d) {
    self.point = point
    super.init(type: .point)
  }
}

public class MultiPoint : Shape {
  public var box: BoundingBox
  public var points: [Point2d] = []
  init(bounds: BoundingBox) {
    box = bounds
    super.init(type: .multipoint)
  }
}

public class Polyline : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  var points: [Point2d] = []
  init(bounds: BoundingBox) {
    box = bounds
    super.init(type: .polyline)
  }
}

public class Polygon : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var points: [Point2d] = []
  init(bounds: BoundingBox) {
    box = bounds
    super.init(type: .polygon)
  }
}

public class PointM : Shape {
  public var point: Point2dm
  init(point: Point2dm) {
    self.point = point
    super.init(type: .pointM)
  }
}

public class MultiPointM : Shape {
  public var box: BoundingBox
  public var measurmentRange: MRange
  public var points: [Point2dm] = []
  init(bounds: BoundingBox, measurmentRange: MRange) {
    self.box = bounds
    self.measurmentRange = measurmentRange
    super.init(type: .multipointM)
  }
}

public class PolylineM : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var points: [Point2dm] = []
  public var measurmentRange: MRange
  init(bounds: BoundingBox, measurmentRange: MRange) {
    self.box = bounds
    self.measurmentRange = measurmentRange


    super.init(type: .polylineM)
  }
}

public class PolygonM : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var points: [Point2dm] = []
  public var measurmentRange: MRange

  init(bounds: BoundingBox, measurmentRange: MRange) {
    self.box = bounds
    self.measurmentRange = measurmentRange
    super.init(type: .polygonM)
  }
}

public class PointZ : Shape {
  public var point: Point3d
  init(point: Point3d) {
    self.point = point
    super.init(type: .pointZ)
  }
}

public class MultiPointZ : Shape {
  public var box: BoundingBox
  public var points: [Point3d] = []
  public var zRange: ZRange
  public var measurmentRange: MRange
  init(bounds: BoundingBox, zRange: ZRange, measurmentRange: MRange) {
    self.box = bounds
    self.zRange = zRange
    self.measurmentRange = measurmentRange
    super.init(type: .multipointZ)
  }
}

public class PolylineZ : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var points: [Point3d] = []
  public var zRange: ZRange
  public var measurmentRange: MRange
  init(bounds: BoundingBox, zRange: ZRange, measurmentRange: MRange) {
    self.box = bounds
    self.zRange = zRange
    self.measurmentRange = measurmentRange
    super.init(type: .polylineZ)
  }
}

public class PolygonZ : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var points: [Point3d] = []
  public var zRange: ZRange
  public var measurmentRange: MRange

  init(bounds: BoundingBox, zRange: ZRange, measurmentRange: MRange) {
    self.box = bounds
    self.zRange = zRange
    self.measurmentRange = measurmentRange
    super.init(type: .polylineZ)
  }
}

public class Multipatch : Shape {
  public var box: BoundingBox
  public var parts: [Int] = []
  public var partTypes: [PartType] = []
  public var points: [Point3d] = []
  public var zRange: ZRange
  public var measurmentRange: MRange

  init(bounds: BoundingBox, zRange: ZRange, measurmentRange: MRange) {
    self.box = bounds
    self.zRange = zRange
    self.measurmentRange = measurmentRange
    super.init(type: .polylineZ)
  }
}

public struct ShapeFileGeometry {
  public var header: ShapeFileHeader
  public var records: [Shape] = []

  func debugPrint() {
    print("\(header)")
    print("Number of records: \(records.count)")

    for record in records {
      if let poly = record as? Polygon {
        print("Polygon: \(poly.parts.count) \(poly.points.count)")
      }
    }
  }
}
