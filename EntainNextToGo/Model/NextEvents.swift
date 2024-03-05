//
//  NextEvents.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import Foundation

struct NextEvents: Decodable {
    typealias EventSummaries = [String: Event]
    enum CodingKeys: String, CodingKey {
      case eventSummaries = "race_summaries"
      case eventIds = "next_to_go_ids"
    }

    let eventIds: [String]
    let eventSummaries: EventSummaries

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventIds = try container.decode([String].self, forKey: CodingKeys.eventIds)
        self.eventSummaries = try container.decode(EventSummaries.self, forKey: CodingKeys.eventSummaries)
    }
}

extension NextEvents {
    init(eventIds: [String], eventSummaries: NextEvents.EventSummaries) {
        self.eventIds = eventIds
        self.eventSummaries = eventSummaries
    }
}
