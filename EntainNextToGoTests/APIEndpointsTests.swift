//
//  NedsAPITests.swift
//  EntainNextToGoTests
//
//  Created by Raunak Singh on 10/3/2024.
//

@testable import EntainNextToGo
import XCTest

final class APIEndpointsTests: XCTestCase {

  func testAPIEndpoints() {
      XCTAssertEqual(NedsAPI.baseURLComponents, URLComponents(string: "https://api.neds.com.au/rest/v1/racing/"))

      var urlComponents = NedsAPI.baseURLComponents
      urlComponents?.queryItems = NedsAPI.nextToJumpQueryParameters(forCount: 10)
      XCTAssertEqual(urlComponents?.url?.absoluteString, "https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10")
  }
}
