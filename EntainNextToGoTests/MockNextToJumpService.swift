//
//  MockNextToJumpService.swift
//  EntainNextToGoTests
//
//  Created by Raunak Singh on 10/3/2024.
//

@testable import EntainNextToGo
import Combine
import XCTest

struct MockNextToGoService: NextToGoProtocol {
    enum MockError: Error {
      case noDataFound
    }

    let publisher: PassthroughSubject<[EntainNextToGo.Event], Error>

    init(publisher: PassthroughSubject<[EntainNextToGo.Event], Error>) {
        self.publisher = publisher
    }

    func getNextEvents(count: Int) -> AnyPublisher<[EntainNextToGo.Event], Error> {
        publisher.eraseToAnyPublisher()
    }
}

extension MockNextToGoService {
    static func makeMockNextEvents() -> [Event] {
        do {
            let data = try Data(contentsOf: try XCTUnwrap(Bundle.main.url(forResource: "mockResponse", withExtension: "json")))
            let response = try JSONDecoder().decode(NextToJumpData.self, from: data)


            let updatedEventSummaries = response.data.eventSummaries.mapValues {
                Event(id: $0.id, name: $0.meetingName, number: $0.number, meetingName: $0.meetingName, startTime: makeRandomStartTime(), racingType: $0.racingType)
            }

            let updatedNextEvents = NextEvents(eventIds: response.data.eventIds, eventSummaries: updatedEventSummaries)

            return updatedNextEvents.eventSummaries.values.map { $0 }
        } catch {
            return []
        }
    }

    static func makeMockEvent() -> Event {
        .init(
            id: "123",
            name: "TestEvent",
            number: 1,
            meetingName: "TestMeeting",
            startTime: {
                do {
                    return try XCTUnwrap(Calendar.current.date(byAdding: .second, value: -55, to: Date()))
                } catch {
                    return Date()
                }
            }(),
            racingType: .horseRacing
        )
    }

    // generating a start time for a rance between now +2 mins and 30 mins, else all mock events are going to be in the past
    static private func makeRandomStartTime() -> Date {
        // genrating a random timeinterval in sceonds
        let randomisingSeconds = Int.random(in: 120..<1800)
        let randomStartTime = Calendar.current.date(byAdding: .second, value: randomisingSeconds, to: Date())

        do {
            return try XCTUnwrap(randomStartTime)
        } catch {
            return Date()
        }
    }
}
