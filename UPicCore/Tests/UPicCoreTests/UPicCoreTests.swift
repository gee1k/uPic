//
//  UPicCoreTests.swift
//  
//
//  Created by Svend Jin on 2020/9/29.
//

import XCTest
@testable import UPicCore

final class UPicCoreTests: XCTestCase {
    func testLocalization() {
        print(HostType.baidu_bos.name)
    }

    static var allTests = [
        ("testLocalization", testLocalization),
    ]
}
