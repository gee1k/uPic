![swiftyxmlparserlogo](https://user-images.githubusercontent.com/18320004/31585849-abf82a6a-b203-11e7-9494-007cebd29aa6.png)

![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/SwiftyXMLParser.svg?style=flat)](http://cocoapods.org/pods/SwiftyXMLParser)
[![License](https://img.shields.io/cocoapods/l/SwiftyXMLParser.svg?style=flat)](http://cocoapods.org/pods/SwiftyXMLParser)
 ![Platform](https://img.shields.io/badge/platforms-iOS%208.0+%20%7C%20macOS%2010.10+%20%7C%20tvOS%209.0+-333333.svg)

Simple XML Parser implemented in Swift

# What's this?
This is a XML parser inspired by [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and  [SWXMLHash](https://github.com/drmohundro/SWXMLHash).

[NSXMLParser](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSXMLParser_Class/) in Foundation framework is a kind of "SAX" parser. It has enough performance but is a little inconvenient. So we have implemented "DOM" parser wrapping it. 

# Feature
- [x] access XML Document with "subscript".
- [x] access XML Document as Sequence.
- [x] easy debugging XML pathes.

# Requirement
+ iOS 8.0+
+ tvOS 9.0+
+ macOS 10.10+
+ Swift 5.0

# Installation

### Carthage
#### 1. create Cartfile

```ruby:Cartfile
github "https://github.com/yahoojapan/SwiftyXMLParser"

```
#### 2. install
```
> carthage update
```

### CocoaPods
#### 1. create Podfile
```ruby:Podfile
platform :ios, '8.0'
use_frameworks!

pod "SwiftyXMLParser", :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
```

#### 2. install
```
> pod install
```

# Example

```swift
import SwiftyXMLParser

let str = """
<ResultSet>
    <Result>
        <Hit index=\"1\">
            <Name>Item1</Name>
        </Hit>
        <Hit index=\"2\">
            <Name>Item2</Name>
        </Hit>
    </Result>
</ResultSet>
"""

// parse xml document
let xml = try! XML.parse(str)

// access xml element
let accessor = xml["ResultSet"]

// access XML Text

if let text = xml["ResultSet", "Result", "Hit", 0, "Name"].text {
    print(text)
}

if let text = xml.ResultSet.Result.Hit[0].Name.text {
    print(text)
}

// access XML Attribute
if let index = xml["ResultSet", "Result", "Hit", 0].attributes["index"] {
    print(index)
}

// enumerate child Elements in the parent Element
for hit in xml["ResultSet", "Result", "Hit"] {
    print(hit)
}

// check if the XML path is wrong
if case .failure(let error) =  xml["ResultSet", "Result", "TypoKey"] {
    print(error)
}
```

# Usage
### 1. Parse XML
+ from String
```swift
let str = """
<ResultSet>
    <Result>
        <Hit index=\"1\">
            <Name>Item1</Name>
        </Hit>
        <Hit index=\"2\">
            <Name>Item2</Name>
        </Hit>
    </Result>
</ResultSet>
"""

xml = try! XML.parse(str) // -> XML.Accessor
```
+ from NSData
```swift
let str = """
<ResultSet>
    <Result>
        <Hit index=\"1\">
            <Name>Item1</Name>
        </Hit>
        <Hit index=\"2\">
            <Name>Item2</Name>
        </Hit>
    </Result>
</ResultSet>
"""

let data = str.data(using: .utf8)

xml = XML.parse(data) // -> XML.Accessor
```

+ with invalid character

```swift
let srt = "<xmlopening>@ß123\u{1c}</xmlopening>"

let xml = XML.parse(str.data(using: .utf8))

if case .failure(XMLError.interruptedParseError) = xml {
  print("invalid character")
}

```

For more, see https://developer.apple.com/documentation/foundation/xmlparser/errorcode 


### 2. Access child Elements
```swift
let element = xml.ResultSet // -> XML.Accessor
```

### 3. Access grandchild Elements
+ with String
```swift
let element = xml["ResultSet"]["Result"] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
```
+ with Array
```swift
let path = ["ResultSet", "Result"]
let element = xml[path] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
```
+ with Variadic
```swift
let element = xml["ResultSet", "Result"] // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
```
+ with @dynamicMemberLookup
```swift
let element = xml.ResultSet.Result // -> <Result><Hit index=\"1\"><Name>Item1</Name></Hit><Hit index=\"2\"><Name>Item2</Name></Hit></Result>
```
### 4. Access specific grandchild Element
```swift
let element = xml.ResultSet.Result.Hit[1] // -> <Hit index=\"2\"><Name>Item2</Name></Hit>
```
### 5. Access attribute in Element
```swift
if let attributeValue = xml.ResultSet.Result.Hit[1].attributes?["index"] {
  print(attributeValue) // -> 2
}
```
### 6. Access text in Element
+ with optional binding
```swift
if let text = xml.ResultSet.Result.Hit[1].Name.text {
    print(text) // -> Item2
} 
```
+ with custom operation
```swift
struct Entity {
  var name = ""
}
let entity = Entity()
entity.name ?= xml.ResultSet.Result.Hit[1].Name.text // assign if it has text
```
+ convert Int and assign
```swift
struct Entity {
  var name: Int = 0
}
let entity = Entity()
entity.name ?= xml.ResultSet.Result.Hit[1].Name.int // assign if it has Int
```
and there are other syntax sugers, bool, url and double.
+ assign text into Array
```swift
struct Entity {
  var names = [String]()
}
let entity = Entity()
entity.names ?<< xml.ResultSet.Result.Hit[1].Name.text // assign if it has text
```
### 7. Count child Elements
```swift
let numberOfHits = xml.ResultSet.Result.Hit.all?.count 
```
### Check error
```swift
print(xml.ResultSet.Result.TypoKey) // -> "TypoKey not found."
```

### Access as SequenceType
+ for-in
```swift
for element in xml.ResultSet.Result.Hit {
  print(element.text)
}
```
+ map
```swift
xml.ResultSet.Result.Hit.map { $0.Name.text }
```

## Work with Alamofire
SwiftyXMLParser goes well with [Alamofire](https://github.com/Alamofire/Alamofire). You can parse the response easily.

```swift
import Alamofire
import SwiftyXMLParser

Alamofire.request(.GET, "https://itunes.apple.com/us/rss/topgrossingapplications/limit=10/xml")
         .responseData { response in
            if let data = response.data {
                let xml = XML.parse(data)
                print(xml.feed.entry[0].title.text) // outputs the top title of iTunes app raning.
            }
        }
```

In addition, there is the extension of Alamofire to combine with SwiftyXMLParser. 

* [Alamofire-SwiftyXMLParser](https://github.com/kazuhiro4949/Alamofire-SwiftyXMLParser)

# Migration Guide
[Current master branch](https://github.com/yahoojapan/SwiftyXMLParser/tree/master) is supporting Xcode10.
If you wanna use this library with legacy swift version, read [release notes](https://github.com/yahoojapan/SwiftyXMLParser/releases) and install the last compatible version.

# License

This software is released under the MIT License, see LICENSE.
