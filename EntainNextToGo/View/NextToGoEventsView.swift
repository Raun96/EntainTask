//
//  NextToGoEventsView.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import SwiftUI

struct NextToGoEventsView: View {
    let events: [Event]
    private let startDate = Date()

    var body: some View {
        List(events) {
            EventRow(event: $0)
                .listRowSeparator(.hidden)
        }
    }
}
