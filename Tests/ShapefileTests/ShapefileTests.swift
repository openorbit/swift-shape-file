import Testing
import TestData
import Numerics

@testable import Shapefile

// We use the same test data as we find in shapelib:
//   https://github.com/OSGeo/shapelib/blob/master/tests/expect1.out
@Suite(.serialized) struct ShapefileTests {
  
  @Test func annoFile() async throws {
    let (shp, _) = testDataURL(name: "TestData/shape_eg_data/anno")

    let baseURL = shp.deletingPathExtension()

    let shape = try Shapefile(url: baseURL)

    #expect(shape.geo.header.boundingBox.minX == 471276.28125)
    #expect(shape.geo.header.boundingBox.minY == 4751595.5)
    #expect(shape.geo.header.boundingBox.maxX.isApproximatelyEqual(to: 492683.536178589))
    #expect(shape.geo.header.boundingBox.maxY.isApproximatelyEqual(to: 4765390.41258159))
    #expect(shape.geo.header.shapeType == .polygon)
    
    #expect(shape.geo.records.count == 201)
    
    #expect(shape.geo.records[0].type == .polygon)
    let poly = shape.geo.records[0] as! Polygon
    #expect(poly.parts.count == 1)
    #expect(poly.points.count == 5)
    #expect(poly.points[0].x.isApproximatelyEqual(to: 486089.53125))
    #expect(poly.points[0].y.isApproximatelyEqual(to: 4764549.5))
    
    
    #expect(shape.dbf.records.count == 201)
    let cols = shape.dbf.fields
    
    #expect(cols.count == 10)
    #expect(cols[0].columnType == .NUMERIC)
    #expect(cols[0].name == "NAME_")
    #expect(cols[0].length == 11)
    #expect(cols[1].columnType == .NUMERIC)
    #expect(cols[1].name == "NAME_ID")
    #expect(cols[2].columnType == .NUMERIC)
    #expect(cols[2].name == "X")
    #expect(cols[3].columnType == .NUMERIC)
    #expect(cols[4].columnType == .NUMERIC)
    #expect(cols[5].columnType == .NUMERIC)
    #expect(cols[6].columnType == .NUMERIC)
    #expect(cols[7].columnType == .NUMERIC)
    #expect(cols[8].columnType == .NUMERIC)
    #expect(cols[9].columnType == .STRING)
  }
  
  
  
  @Test func pline() async throws {
    let (shp, dbf) = testDataURL(name: "TestData/shape_eg_data/pline")
    
    let shape = try Shapefile(dbfURL: dbf, geoURL: shp)

    #expect(shape.geo.header.boundingBox.minX.isApproximatelyEqual(to: 1296367.5))
    #expect(shape.geo.header.boundingBox.minY.isApproximatelyEqual(to: 228199.390625))
    #expect(shape.geo.header.boundingBox.maxX.isApproximatelyEqual(to: 1302699.0))
    #expect(shape.geo.header.boundingBox.maxY.isApproximatelyEqual(to: 237185.03125))
    #expect(shape.geo.header.shapeType == .polyline)
    
    #expect(shape.dbf.records.count == 460)
    
    let cols = shape.dbf.fields
    
    #expect(cols.count == 19)
    
    #expect(cols[4].columnType == .FLOAT)
    #expect(cols[4].name == "LENGTH")
    #expect(cols[18].columnType == .STRING)
    #expect(cols[18].name == "CMPN")
  }
  
  
  @Test func polygon() async throws {
    let (shp, dbf) = testDataURL(name: "TestData/shape_eg_data/polygon")

    let shape = try Shapefile(dbfURL: dbf, geoURL: shp)

    #expect(shape.geo.header.boundingBox.minX.isApproximatelyEqual(to: 471127.1875))
    #expect(shape.geo.header.boundingBox.minY.isApproximatelyEqual(to: 4751545))
    #expect(shape.geo.header.boundingBox.maxX.isApproximatelyEqual(to: 489292.3125))
    #expect(shape.geo.header.boundingBox.maxY.isApproximatelyEqual(to: 4765610.5))
    #expect(shape.geo.header.shapeType == .polygon)

    #expect(shape.count == 474)
    #expect(shape.dbf.records.count == 474)
    
    let cols = shape.dbf.fields
    
    #expect(cols.count == 29)
    let (lastShape, lastRow) = shape[473]
    #expect(lastShape.type == .polygon)
    #expect(lastRow["AA"] == .int(35044125))

    let poly = shape.geo.records[0] as! Polygon
    #expect(poly.box.minX.isApproximatelyEqual(to: 479647))
    #expect(poly.box.minY.isApproximatelyEqual(to: 4764856.5))
    #expect(poly.box.maxX.isApproximatelyEqual(to: 480389.6875))
    #expect(poly.box.maxY.isApproximatelyEqual(to: 4765610.5))
    #expect(poly.parts.count == 1)
    #expect(poly.parts[0] == 0)
    #expect(poly.points.count == 20)
    
    #expect(poly.points[0].x.isApproximatelyEqual(to: 479819.84375))
    #expect(poly.points[0].y.isApproximatelyEqual(to: 4765180.5))
    
    #expect(poly.points[1].x.isApproximatelyEqual(to: 479690.1875))
    #expect(poly.points[1].y.isApproximatelyEqual(to: 4765259.5))
    
    #expect(poly.points[2].x.isApproximatelyEqual(to: 479647))
    #expect(poly.points[2].y.isApproximatelyEqual(to: 4765369.5))
    
    
    #expect(poly.points[3].x.isApproximatelyEqual(to: 479730.375))
    #expect(poly.points[3].y.isApproximatelyEqual(to: 4765400.5))
    
    #expect(poly.points[4].x.isApproximatelyEqual(to: 480039.03125))
    #expect(poly.points[4].y.isApproximatelyEqual(to: 4765539.5))
    #expect(poly.points[5].x.isApproximatelyEqual(to: 480035.34375))
    #expect(poly.points[5].y.isApproximatelyEqual(to: 4765558.5))
    #expect(poly.points[6].x.isApproximatelyEqual(to: 480159.78125))
    #expect(poly.points[6].y.isApproximatelyEqual(to: 4765610.5))
    #expect(poly.points[7].x.isApproximatelyEqual(to: 480202.28125))
    #expect(poly.points[7].y.isApproximatelyEqual(to: 4765482))
    #expect(poly.points[8].x.isApproximatelyEqual(to: 480365))
    #expect(poly.points[8].y.isApproximatelyEqual(to: 4765015.5))
    #expect(poly.points[9].x.isApproximatelyEqual(to: 480389.6875))
    #expect(poly.points[9].y.isApproximatelyEqual(to: 4764950))
    #expect(poly.points[10].x.isApproximatelyEqual(to: 480133.96875))
    #expect(poly.points[10].y.isApproximatelyEqual(to: 4764856.5))
    #expect(poly.points[11].x.isApproximatelyEqual(to: 480080.28125))
    #expect(poly.points[11].y.isApproximatelyEqual(to: 4764979.5))
    #expect(poly.points[12].x.isApproximatelyEqual(to: 480082.96875))
    #expect(poly.points[12].y.isApproximatelyEqual(to: 4765049.5))
    #expect(poly.points[13].x.isApproximatelyEqual(to: 480088.8125))
    #expect(poly.points[13].y.isApproximatelyEqual(to: 4765139.5))
    #expect(poly.points[14].x.isApproximatelyEqual(to: 480059.90625))
    #expect(poly.points[14].y.isApproximatelyEqual(to: 4765239.5))
    #expect(poly.points[15].x.isApproximatelyEqual(to: 480019.71875))
    #expect(poly.points[15].y.isApproximatelyEqual(to: 4765319.5))
    #expect(poly.points[16].x.isApproximatelyEqual(to: 479980.21875))
    #expect(poly.points[16].y.isApproximatelyEqual(to: 4765409.5))
    #expect(poly.points[17].x.isApproximatelyEqual(to: 479909.875))
    #expect(poly.points[17].y.isApproximatelyEqual(to: 4765370))
    #expect(poly.points[18].x.isApproximatelyEqual(to: 479859.875))
    #expect(poly.points[18].y.isApproximatelyEqual(to: 4765270))
    #expect(poly.points[19].x.isApproximatelyEqual(to: 479819.84375))
    #expect(poly.points[19].y.isApproximatelyEqual(to: 4765180.5))
    
  }
  
}
