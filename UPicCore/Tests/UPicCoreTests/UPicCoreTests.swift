//
//  UPicCoreTests.swift
//
//
//  Created by Svend Jin on 2020/9/29.
//

@testable import UPicCore
import XCTest

final class UPicCoreTests: XCTestCase {
    func testLocalization() {
        print(HostType.baidu_bos.name)
    }

    static var allTests = [
        ("testLocalization", testLocalization),
    ]
}
