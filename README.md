# README

Implementation of ESRI shapefile parsing in Swift.
The library does not support ESRI shapefile serialization.

This package is under development.

The shapefile reader and rest of the framework here is under the
Apache 2.0 license.

The library depends on the swift-binary-parsing package:
https://github.com/apple/swift-binary-parsing

Test data has been taken from https://github.com/OSGeo/shapelib
which took it from http://dl.maptools.org/dl/shapelib/shape_eg_data.zip

## Limitations

- Reads data into memory, you may have issues with larger data sets
- DBF reader is not thuroughly tested, only supports a subste of column types
