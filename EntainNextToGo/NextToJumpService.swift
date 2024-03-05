//
//  NextToJumpService.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 9/3/2024.
//

import Foundation
import Combine

protocol NextToGoProtocol {
    func getNextEvents(count: Int) -> AnyPublisher<[Event], Error>
}

struct NextToGoService: NextToGoProtocol {
    enum NextToGoError: Error {
        case noData
        case invalidURL
    }

    func getNextEvents(count: Int) -> AnyPublisher<[Event], Error> {
        var urlComponents = NedsAPI.baseURLComponents
        urlComponents?.queryItems = NedsAPI.nextToJumpQueryParameters(forCount: count)

        guard let url = urlComponents?.url else {
            return Fail<[Event], Error>(error: NextToGoError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                return data
            }
            .decode(type: NextToJumpData.self, decoder: JSONDecoder())
            .map { response in
                return response.data.eventSummaries.values.map { $0 }
            }
            .eraseToAnyPublisher()
    }
}
