/**
 * The MIT License (MIT)
 *
 * Copyright (C) 2016 Yahoo Japan Corporation.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

extension XML {
    
    /**
     Class for accessing XML Document as SequenceType.
     
     defined as enumeration which has three states
     - SingleElement
       - accesssed the specific XML Element from XML Path
     - Sequence
       - accessed multiple Elements from XML Path
     - Failure
       - wrong XML Path
     
     
    */
    @dynamicMemberLookup
    public enum Accessor: CustomStringConvertible, Swift.Sequence {
        case singleElement(Element)
        case sequence([Element])
        case failure(Error)
        
        public init(_ element: Element) {
            self = .singleElement(element)
        }
        
        public init(_ sequence: [Element]) {
            self = .sequence(sequence)
        }
        
        public init(_ error: Error) {
            self = .failure(error)
        }
        
        
        public subscript(dynamicMember member: String) -> XML.Accessor {
            return self[member]
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         
         ```
         let hit = xml[1][2][3]
         ```
         
         
         The same as:
         ```
         let hit = xml[1, 2, 3]
         ```
         
         or :
         ```
         let path = [1, 2, 3]
         let hit = xml[path]
         ```
         
         */
        fileprivate subscript(index index: Int) -> Accessor {
            let accessor: Accessor
            switch self {
            case .sequence(let elements) where index < elements.count:
                accessor =  Accessor(elements[index])
            case .singleElement(let element) where index == 0:
                accessor = Accessor(element)
            case .failure(let error):
                accessor = Accessor(error)
                break
            default:
                let error = accessError("cannot access Index: \(index)")
                accessor = Accessor(error)
                break
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         
         ```
         let hit = xml["ResultSet"]["Result"]["Hit"]
         ```

         
         The same as:
         ```
         let hit = xml["ResultSet", "Result", "Hit"]
         ```
         
         or :
         ```
         let path = ["ResultSet", "Result", "Hit"]
         let hit = xml[path]
         ```
         
         */
        fileprivate subscript(key key: String) -> Accessor {
            let accessor: Accessor
            switch self {
            case .singleElement(let element):
                let filterdElements = element.childElements.filter { $0.name == key }
                if filterdElements.isEmpty {
                    let error = accessError("\(key) not found.")
                    accessor =  Accessor(error)
                } else if filterdElements.count == 1 {
                    accessor =  Accessor(filterdElements[0])
                } else {
                    accessor =  Accessor(filterdElements)
                }
            case .failure(let error):
                accessor =  Accessor(error)
            case .sequence(_):
                fallthrough
            default:
                let error = accessError("cannot access \(key), because of multiple elements")
                accessor =  Accessor(error)
                break
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         ```
         let path = ["ResultSet", "Result", "Hit", 0]
         let hit = xml[path]
         ```

         The same as:
         ```
         let hit = xml["ResultSet", "Result", "Hit", 0]
         ```

         or :
         
         ```
         let hit = xml["ResultSet"]["Result"]["Hit"][0]
         ```
         */
        public subscript(path: Array<XMLSubscriptType>) -> Accessor {
            var accessor = self
            for position in path {
                switch position {
                case let index as Int:
                    accessor = accessor[index]
                case let key as String:
                    accessor = accessor[key]
                default:
                    let error = accessError("cannot access \(position)")
                    accessor = Accessor(error)
                }
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         ```
         let hit = xml["ResultSet", "Result", "Hit", 0]
         ```
         
         
         The same as:
         
         ```
           let path = ["ResultSet", "Result", "Hit", 0]
           let hit = xml[path]
         ```
         or :
         
         ```
           let hit = xml["ResultSet"]["Result"]["Hit"][0]
         ```
         */
        public subscript(path: XMLSubscriptType...) -> Accessor {
            var accessor = self
            for position in path {
                switch position {
                case let index as Int:
                    accessor = accessor[index: index]
                case let key as String:
                    accessor = accessor[key: key]
                default:
                    let error = accessError("cannot access \(position)")
                    accessor = Accessor(error)
                }
            }
            return accessor
        }
        
        public var name: String? {
            let name: String?
            switch self {
            case .singleElement(let element):
                name = element.name
            case .failure(_), .sequence(_):
                fallthrough
            default:
                name = nil
                break
            }
            return name
        }
        
        public var text: String? {
            let text: String?
            switch self {
            case .singleElement(let element):
                text = element.text
            case .failure(_), .sequence(_):
                fallthrough
            default:
                text = nil
                break
            }
            return text
        }
        
        
        /// syntax sugar to access Bool Text
        public var bool: Bool? {
            return text.flatMap { $0 == "true" }
        }
        
        
        /// syntax sugar to access URL Text
        public var url: URL? {
            return text.flatMap({URL(string: $0)})
        }
        
        /// syntax sugar to access Int Text
        public var int: Int? {
            return text.flatMap({Int($0)})
        }
        
        /// syntax sugar to access Double Text
        public var double: Double? {
            return text.flatMap({Double($0)})
        }
        
        /// access to XML Attributes
        public var attributes: [String: String] {
            let attributes: [String: String]
            switch self {
            case .singleElement(let element):
                attributes = element.attributes
            case .failure(_), .sequence(_):
                fallthrough
            default:
                attributes = [String: String]()
                break
            }
            return attributes
        }
        
        /// access to child Elements
        public var all: [Element]? {
            switch self {
            case .singleElement(let element):
                return [element]
            case .sequence(let elements):
                return elements
            case .failure(_):
                return nil
            }
        }
        
        /// access to child Elemnet Tag Names
        public var names: [String]? {
            switch self {
            case .singleElement(let element):
                return [element.name]
            case .sequence(let elements):
                return elements.map { $0.name }
            case .failure(_):
                return nil
            }
        }
        
        /// if it has wrong XML path, return Error, otherwise return nil
        public var error: Error? {
            switch self {
            case .failure(let error):
                return error
            case .singleElement(_), .sequence(_):
                return nil
            }
        }
        
        
        /// if it has wrong XML path or multiple child elements, return nil, otherwise return Element
        public var element: Element? {
            switch self {
            case .singleElement(let element):
                return element
            case .failure(_), .sequence(_):
                return nil
            }
        }
        
        /// if it has wrong XML path or no child Element, return nil, otherwise return last Element
        public var last: Accessor {
            switch self {
            case .singleElement(let element):
                return Accessor(element)
            case .sequence(let elements):
                if let lastElement = elements.last {
                    return Accessor(lastElement)
                } else {
                    return Accessor(accessError("cannot access last element"))
                }
            case .failure(let error):
                return Accessor(error)
            }
        }
        
        /// if it has wrong XML path or no child Element, return nil, otherwise return first Element
        public var first: Accessor {
            switch self {
            case .singleElement(let element):
                return Accessor(element)
            case .sequence(let elements):
                if let firstElement = elements.first {
                    return Accessor(firstElement)
                } else {
                    return Accessor(accessError("cannot access first element"))
                }
            case .failure(let error):
                return Accessor(error)
            }
        }
        
        public func map<T>(_ transform: (Accessor) -> T) -> [T] {
            switch self {
            case .singleElement(let element):
                return [Accessor(element)].map(transform)
            case .sequence(let elements):
                return elements.map({ Accessor($0) }).map(transform)
            case .failure:
                return [Accessor]().map(transform)
            }
        }

        @available(*, renamed:"flatMap")
        public func mapWithSqueezeNil<T>(_ transform: (Accessor) -> T?) -> [T] {
            var accessors = [Accessor]()
            switch self {
            case .singleElement(let element):
                accessors = [Accessor(element)]
            case .sequence(let elements):
                accessors = elements.map({ Accessor($0) })
            case .failure:
                accessors = [Accessor]()
            }
            return accessors.reduce([T]()) {
                let transformed = transform($1)
                if let unwrappedTransform = transformed {
                    return $0 + [unwrappedTransform]
                } else {
                    return $0
                }
            }
        }

        // MARK: - SequenceType
        
        public func makeIterator() -> AnyIterator<Accessor> {
            let generator: [XML.Element]
            switch self {
            case .failure(_):
                generator = []
            case .singleElement(let element):
                generator = [element]
            case .sequence(let elements):
                generator = elements
            }
            var index = 0
            return AnyIterator {
                let nextAccessor: Accessor?
                if index < generator.count {
                    nextAccessor = Accessor(generator[index])
                    index += 1
                } else {
                    nextAccessor = nil
                }
                return nextAccessor
            }
        }
        
        
        // MARK: - CustomStringConvertible
        
        public var description: String {
            switch self {
            case .singleElement(let element):
                return "\"" + self.recursivePrintAncient(element) + "\""
            case .sequence(let elements):
                let descriptions = elements.map { self.recursivePrintAncient($0) }
                return "[ " + descriptions.joined(separator: ",\n ") + " ]"
            case .failure(let error):
                return "\(error)"
            }
        }
        
        fileprivate func recursivePrintAncient(_ element: Element) -> String {
            var description = element.name
            if let unwrappedParent = element.parentElement {
                description = recursivePrintAncient(unwrappedParent) + " > " + description
            }
            return description
        }
        
        fileprivate func accessError(_ description: String) -> Error {
            return XMLError.accessError(description: description)
        }
    }
}

extension XML {
    /// Conveter to make xml document from Accessor.
    public class Converter {
        let accessor: XML.Accessor

        public init(_ accessor: XML.Accessor) {
            self.accessor = accessor
        }
        
        /**
         If Accessor object has correct XML path, return the XML element, otherwith return error
         
         example:
         
         ```
         let xml = try! XML.parse("<?xml version="1.0" encoding="UTF-8"?><doc><name key="value">text</name></doc>")
         let elem = xml.doc
         
         print(Converter(elem).makeDocument())
         // => <?xml version="1.0" encoding="UTF-8"?><name key="value">text</name>
         ```
         
         */
        public func makeDocument() throws -> String {
            if case .failure(let err) = accessor {
                throw err
            }

            var doc: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            for hit in accessor {
                switch hit {
                case .singleElement(let element):
                    doc += traverse(element)
                case .sequence(let elements):
                    doc += elements.reduce("") { (sum, el) in sum + traverse(el) }
                case .failure(let error):
                    throw error
                }
            }

            return doc
        }

        private func traverse(_ element: Element) -> String {
            let name = element.name
            let text = element.text ?? ""
            let attrs = element.attributes.map { (k, v) in "\(k)=\"\(v)\""  }.joined(separator: " ")

            let childDocs = element.childElements.reduce("", { (result, element) in
                result + traverse(element)
            })

            if name == "XML.Parser.AbstructedDocumentRoot" {
                return childDocs
            } else {
                return "<\(name) \(attrs)>\(text)\(childDocs)</\(name)>"
            }
        }
    }
}
