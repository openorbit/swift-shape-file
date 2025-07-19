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

public struct Shapefile {
  public var dbf: DBF
  public var geo: ShapeFileGeometry

  public init(url: URL) throws {
    let dbfURL = url.appendingPathExtension("dbf")
    let geoURL = url.appendingPathExtension("shp")
    try self.init(dbfURL: dbfURL, geoURL: geoURL)
  }

  init(dbfURL: URL, geoURL: URL) throws
  {
    let dbfData = try Data(contentsOf: dbfURL)
    self.dbf = try DBF(parsing: dbfData)

    let geoData = try Data(contentsOf: geoURL)
    self.geo = try ShapeFileGeometry(parsing: geoData)
  }
}
