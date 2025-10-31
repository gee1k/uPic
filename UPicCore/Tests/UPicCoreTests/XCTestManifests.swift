//
//  XCTestManifests.swift
//
//
//  Created by Svend Jin on 2020/9/29.
//
import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(UPicCoreTests.allTests),
    ]
}
#endif
