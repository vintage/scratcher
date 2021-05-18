## 2.1.0

* Rebuild scratcher on constraints resize through `rebuildOnResize` parameter
* Fix null-related crash (by @pcvdheuvel)

## 2.0.1

* Fix nullable image

## 2.0.0

* Migrate package to null safety

## 1.6.0

* Added `enabled` parameter to control whether new scratches can be applied

## 1.5.0

* Support WEB platform

## 1.4.2

* Fix painting error

## 1.4.1

* Add new callbacks to track scratching events

## 1.4.0

* Fixed image support in Flutter 1.20
* Added support for dynamic brush size
* Fixed threshold reporting when using reset/reveal methods
* Updated example project

## 1.3.0

* Added `image` to support for asset, network & memory images
* Removed `imagePath` (use `image: Image.asset(...)` instead)
* Removed `imageFit` (configure through `image` fields instead)

## 1.2.1

* Fix issue with scratch area size 

## 1.2.0

* Removed revealDuration parameter - same effect can be now achieved through `reveal()` method
* Added programmatic access to scratch widget - `reset()` and `reveal()` methods
* Minor performance improvements and memory management 

## 1.1.0

* Added revealDuration parameter to automatically reveal area on threshold
* Major performance improvements

## 1.0.0

* Added accuracy parameter to control performance level
* Improved algorithm calculating the progress
* Fixed size of the scratch area
* More fun & complex example

## 0.0.5

* Improve code quality (pedantic)

## 0.0.4

* Fix scratcher size

## 0.0.3

* Readme images

## 0.0.2

* Extend documentation
* Add example project

## 0.0.1

* Initial release
