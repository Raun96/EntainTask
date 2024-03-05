//
//  Helpers.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import Foundation

var isProduction: Bool {
    NSClassFromString("XCTestCase") == nil
}
