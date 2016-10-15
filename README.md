# GNThreadPool

[![CI Status](http://img.shields.io/travis/games-neox/GNThreadPool.svg?style=flat)](https://travis-ci.org/games-neox/GNThreadPool)
[![Version](https://img.shields.io/cocoapods/v/GNThreadPool.svg?style=flat)](http://cocoapods.org/pods/GNThreadPool)
[![License](https://img.shields.io/cocoapods/l/GNThreadPool.svg?style=flat)](http://cocoapods.org/pods/GNThreadPool)
[![Platform](https://img.shields.io/cocoapods/p/GNThreadPool.svg?style=flat)](http://cocoapods.org/pods/GNThreadPool)

Simple thread pool for Objective-C/Swift.
Basis usage:
```objective-c
#import <GNThreadPool/GNThreadPool.h>

GNThreadPool* threadPool = [[GNThreadPool alloc] initWithThreadsAmount:4 withPriority:GNThreadPriorityHigher];

[threadPool enqueue:^{
    NSLog(@"in a separate thread");
}];

[threadPool clear];
```  
```swift
import GNThreadPool

let threadPool = GNThreadPool(threadsAmount: 4,  withPriority: .Higher)

threadPool.enqueue() {
    NSLog("in a separate thread")
}

threadPool.clear()
```

Inspiried by Jakob Progsch, Václav Zeman, 2012

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Minimum supported `iOS` version: `8.x`  
Dependencies: `GNExceptions`, `GNLog` & `GNPreconditions`

## Installation

GNThreadPool is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "GNThreadPool"
```

## Author

Games Neox, games.neox@gmail.com

## License

GNThreadPool is available under the MIT license. See the LICENSE file for more info.
