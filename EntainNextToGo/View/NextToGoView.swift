//
//  ContentView.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import SwiftUI
import Combine

struct NextToGoView: View {
    @StateObject var viewModel: NextToGoViewModel

    @State private var selectedRacingType: RacingType? = nil
    @State private var selectedRacingTypes = Set<RacingType>()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading")
                case .loaded(let nextEvents):
                    NextToGoEventsView(events: nextEvents)
                case .error:
                    Text("Something went wrong, please try again later!!")
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .onChange(of: selectedRacingTypes, {
                viewModel.inputs.selectedRacingTypes.send(selectedRacingTypes)
            })
            .toolbar(content: toolbarContent)
            .navigationTitle("Next to Go")
        }
    }

    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            Menu {
                ForEach(RacingType.allCases) { racingType in
                    Button(action: {
                        if selectedRacingTypes.contains(racingType) {
                            selectedRacingTypes.remove(racingType)
                        } else {
                            selectedRacingTypes.insert(racingType)
                        }
                    }, label: {
                        HStack(spacing: 16) {
                            Text(racingType.title)

                            if selectedRacingTypes.contains(racingType) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .tag(racingType.id)
                    })
                }
            } label: {
                Label(
                    "Filter",
                    systemImage: selectedRacingTypes.isEmpty ?  "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"
                )
            }
        }
    }
}

#Preview {
    NextToGoView(viewModel: .init(service: NextToGoService()))
}
