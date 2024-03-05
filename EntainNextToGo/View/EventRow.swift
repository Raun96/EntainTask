//
//  EventRow.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 10/3/2024.
//

import SwiftUI

struct EventRow: View {
    let event: Event

    var body: some View {
        ViewThatFits {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2, content: {
                    Text(event.meetingName)
                        .font(.headline)

                    //Would ideally use icons to denote different race types but couldn't find relevant ones in SFSymbols
                    Text(event.racingType.title)
                        .font(.caption)
                })

                Spacer()

                Text("R\(event.number)")
                    .font(.headline)

                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(Formatter.countdownFormatter.string(from: Date(), to: event.startTime) ?? "-")
                }
            }
        }
        .padding(8)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 1)
        }
    }
}
