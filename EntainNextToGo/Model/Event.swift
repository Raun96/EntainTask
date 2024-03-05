//
//  Event.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import Foundation

struct Event: Decodable, Identifiable {
    let id: String
    let name: String
    let number: Int
    let meetingName: String
    let startTime: Date
    let racingType: RacingType

    enum CodingKeys: String, CodingKey {
        case id = "race_id"
        case name = "race_name"
        case number = "race_number"
        case meetingName = "meeting_name"
        case startTime = "advertised_start"
        case racingType = "category_id"
        case seconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startTimeContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: CodingKeys.startTime)

        self.id = try container.decode(String.self, forKey: CodingKeys.id)
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.number = try container.decode(Int.self, forKey: CodingKeys.number)
        self.meetingName = try container.decode(String.self, forKey: CodingKeys.meetingName)
        self.racingType = try container.decode(RacingType.self, forKey: CodingKeys.racingType)
        self.startTime = Date(timeIntervalSince1970: try startTimeContainer.decode(TimeInterval.self, forKey: CodingKeys.seconds))
    }
}

extension Event {
    init(id: String, name: String, number: Int, meetingName: String, startTime: Date, racingType: RacingType) {
        self.id = id
        self.name = name
        self.number = number
        self.meetingName = meetingName
        self.startTime = startTime
        self.racingType = racingType
    }
}
