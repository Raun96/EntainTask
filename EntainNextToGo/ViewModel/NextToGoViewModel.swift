//
//  NextToJumpViewModel.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import Combine
import Foundation

class NextToGoViewModel: ObservableObject {
    @Published var state: State

    let inputs: Inputs

    private var cancellables = Set<AnyCancellable>()
    private var allNextEvents = [Event]()
    private let service: NextToGoProtocol

    init(
        service: NextToGoProtocol,
        inputs: Inputs = Inputs()
    ) {
        self.state = .loading
        self.service = service
        self.inputs = inputs

        let initalStatePublisher: AnyPublisher<State, Never> = loadNextEvents()
            .map {
                self.makeNextState(forSelectedRacingTypes: inputs.selectedRacingTypes.value, events: $0)
            }
            .catch { _ in
                Just(.error)
            }
            .eraseToAnyPublisher()

        let filtersSubjectPublisher: AnyPublisher<State, Never> = inputs.selectedRacingTypes
            .dropFirst()
            .map { [weak self] racingType in
                guard let self = self else { return  .error }
                return self.makeNextState(forSelectedRacingTypes: racingType, events: self.allNextEvents)
            }
            .eraseToAnyPublisher()

        let timeIntervalStatePublisher: AnyPublisher<State, Never> = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .compactMap { [weak self] _ in
                guard let self = self else { return  .error }

                return self.updateLoadedStateIfNeeded()
            }
            .eraseToAnyPublisher()

        let reloadPublisher: AnyPublisher<State, Never> = Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in self.loadNextEvents() }
            .map { self.makeNextState(forSelectedRacingTypes: inputs.selectedRacingTypes.value, events: $0) }
            .catch { _ in Just(.error) }
            .eraseToAnyPublisher()

        let statePublisher = initalStatePublisher.merge(with: filtersSubjectPublisher, timeIntervalStatePublisher, reloadPublisher)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        cancellables.insert(statePublisher.assign(to: \.state, on: self))
    }

    private func loadNextEvents() -> AnyPublisher<[Event], Error> {
        service.getNextEvents(count: 10)
            .map { [weak self] nextEvents in
                self?.allNextEvents = nextEvents
                return nextEvents
            }
            .eraseToAnyPublisher()
    }

    private func updateLoadedStateIfNeeded() -> State? {
        switch state {
        case .loading, .error:
            return nil
        case .loaded:
            return makeNextState(forSelectedRacingTypes: inputs.selectedRacingTypes.value, events: allNextEvents)
        }
    }

    private func makeNextState(forSelectedRacingTypes racingTypes: Set<RacingType>, events: [Event]) -> State {
        var unsortedEvents = [Event]()
        let eventsSortedByRacingTypes = Dictionary(grouping: events) { $0.racingType }

        racingTypes.forEach { type in
            guard let eventByRacingType = eventsSortedByRacingTypes[type] else { return }

            unsortedEvents.append(contentsOf: eventByRacingType)
        }

        let filteredEvents = events.filter {
            //Filtering events that are past 59 seconds
            let isEventPastRunTime = $0.startTime.timeIntervalSinceNow > -59
            guard
                racingTypes.isEmpty == false,
                racingTypes.contains($0.racingType)
            else {
                return racingTypes.isEmpty ? isEventPastRunTime : false
            }

            return isEventPastRunTime
        }.sorted(using: SortDescriptor(\.startTime))

        let nextFiveEvents: [Event] =  {
            switch filteredEvents.count > 5 {
            case true: return Array(filteredEvents.prefix(5))
            case false: return filteredEvents
            }
        }()

        return .loaded(nextEvents: nextFiveEvents)
    }
}

extension NextToGoViewModel {
    enum State: Equatable {
        case loading
        case loaded(nextEvents: [Event])
        case error

        static func == (lhs: NextToGoViewModel.State, rhs: NextToGoViewModel.State) -> Bool {
            switch(lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded(let lhsNextEvents), .loaded(let rhsNextEvents)):
                return lhsNextEvents.elementsEqual(rhsNextEvents, by: { $0.id == $1.id })
            case (.error, .error):
                return true
            default:
                return false
            }
        }

        func isLoaded() -> Bool {
            switch self {
            case .loading, .error:
                return false
            case .loaded:
                return true
            }
        }

        func getNextEvents() -> [Event] {
            switch self {
            case .loading, .error:
                return []
            case .loaded(let nextEvents):
                return nextEvents
            }
        }
    }

    struct Inputs {
        let viewDidAppear: PassthroughSubject<Void, Never>
        let selectedRacingTypes: CurrentValueSubject<Set<RacingType>, Never>

        init(
            selectedRacingTypes: CurrentValueSubject<Set<RacingType>, Never> = CurrentValueSubject<Set<RacingType>, Never>(.init()),
            viewDidAppear: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
        ) {
            self.viewDidAppear = viewDidAppear
            self.selectedRacingTypes = selectedRacingTypes
        }
    }
}
