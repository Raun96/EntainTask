//
//  Constants.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 9/3/2024.
//

import Foundation

struct NedsAPI {
    static let baseURLComponents = URLComponents(string: "https://api.neds.com.au/rest/v1/racing/")

    static func nextToJumpQueryParameters(forCount count: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "method", value: "nextraces"),
            URLQueryItem(name: "count", value: "\(count)")
        ]
    }
}
