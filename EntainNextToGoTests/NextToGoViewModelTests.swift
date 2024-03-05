//
//  NextToGoViewModelTests.swift
//  EntainNextToGoTests
//
//  Created by Raunak Singh on 10/3/2024.
//

@testable import EntainNextToGo
import Combine
import XCTest

final class NextToGoViewModelTests: XCTestCase {

    func testInitialStateIsLoading() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)

        XCTAssertEqual(mockViewModel.state, .loading)
    }

    func testLoadingStateDisplaysFiveEvents() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockViewModel = NextToGoViewModel(service: mockService)
        let expectation = XCTestExpectation(description: "Display 5 Events")
        let mockEvents = MockNextToGoService.makeMockNextEvents()
        XCTAssert(mockEvents.count > 0)

        eventsPublisher.send(mockEvents)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 5)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
    func testErrorState() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let expectation = XCTestExpectation(description: "ViewModel state is Error")
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)

        eventsPublisher.send(completion: .failure(MockNextToGoService.MockError.noDataFound))

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state, .error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testInitaiallySelectedFilter_IsNil() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockViewModel = NextToGoViewModel(service: mockService)

        XCTAssertEqual(mockViewModel.inputs.selectedRacingTypes.value, [])
    }

    //Mock response contains 6 HorseRacing Events, 3 GreyhoundRacing Events and 1 HarnessRacing Event, hence the AssertEquals have magic numbers
    func testAppliedRacingFilterHorseRacingEvents() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)
        let expectation = XCTestExpectation(description: "Filter Applied")
        let mockEvents = MockNextToGoService.makeMockNextEvents()

        XCTAssert(mockEvents.count > 0)
        eventsPublisher.send(mockEvents)
        mockInputs.selectedRacingTypes.send(Set([.horseRacing]))

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 5)
            mockViewModel.state.getNextEvents().forEach {
                XCTAssertEqual($0.racingType, .horseRacing)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testAppliedRacingFilterHarnessRacingEvents() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)
        let expectation = XCTestExpectation(description: "Filter Applied")
        let mockEvents = MockNextToGoService.makeMockNextEvents()

        XCTAssert(mockEvents.count > 0)
        eventsPublisher.send(mockEvents)

        mockInputs.selectedRacingTypes.send(Set([.harnessRacing]))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 1)
            mockViewModel.state.getNextEvents().forEach {
                XCTAssertEqual($0.racingType, .harnessRacing)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testAppliedRacingFilterGreyhoundRacingEvents() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)
        let expectation = XCTestExpectation(description: "Filter Applied")
        let mockEvents = MockNextToGoService.makeMockNextEvents()

        XCTAssert(mockEvents.count > 0)
        eventsPublisher.send(mockEvents)

        mockInputs.selectedRacingTypes.send(Set([.greyhoundRacing]))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 3)
            mockViewModel.state.getNextEvents().forEach {
                XCTAssertEqual($0.racingType, .greyhoundRacing)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    //Adding only one event with a custom startTime
    func testRemovePastEvents() {
        let eventsPublisher = PassthroughSubject<[EntainNextToGo.Event], Error>()
        let mockService = MockNextToGoService(publisher: eventsPublisher)
        let mockInputs = NextToGoViewModel.Inputs()
        let mockViewModel = NextToGoViewModel(service: mockService, inputs: mockInputs)
        let expectation = XCTestExpectation(description: "Remove Event past 1 min. of startTime")

        let mockEvent = MockNextToGoService.makeMockEvent()
        eventsPublisher.send([mockEvent])

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 1)

            guard let event = mockViewModel.state.getNextEvents().first else {
                XCTFail("Something went wrong Can't find mock event")
                return
            }

            XCTAssertEqual(event.id, "123")
            XCTAssertEqual(event.number, 1)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            XCTAssertEqual(mockViewModel.state.getNextEvents().count, 0)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}
