//
//  EntainNextToGoApp.swift
//  EntainNextToGo
//
//  Created by Raunak Singh on 9/3/2024.
//

import SwiftUI

@main
struct EntainNextToGoApp: App {
    var body: some Scene {
        WindowGroup {
            if isProduction {
                NextToGoView(viewModel: .init(service: NextToGoService()))
            } else {
                EmptyView()
            }
        }
    }
}
