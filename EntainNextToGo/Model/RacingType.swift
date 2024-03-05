//
//  RacingType.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import Foundation

enum RacingType: String, Decodable, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }

    case horseRacing = "4a2788f8-e825-4d36-9894-efd4baf1cfae"
    case greyhoundRacing = "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
    case harnessRacing = "161d9be2-e909-4326-8c2c-35ed71fb460b"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let categoryId = try container.decode(String.self)

        self = switch categoryId {
        case Self.greyhoundRacing.rawValue : .greyhoundRacing
        case Self.harnessRacing.rawValue: .harnessRacing
        case Self.horseRacing.rawValue: .horseRacing
        default: throw DecodingError.dataCorrupted(
            .init(codingPath: decoder.codingPath, debugDescription: "Invalid id match on RacingType - \(categoryId) doesn't exist in type \(Self.self)")
        )
        }
    }

    var title: String {
        switch self {
        case .horseRacing: "Horse Racing"
        case .greyhoundRacing: "Greyhound Racing"
        case .harnessRacing: "Harness Racing"
        }
    }
}
