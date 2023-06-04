//
//  TcaTutorialApp.swift
//  TcaTutorial
//
//  Created by Fumiya Tanaka on 2023/06/03.
//

import SwiftUI
import ComposableArchitecture

@main
struct TcaTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            CounterView(
                store: Store(initialState: CounterFeature.State(), reducer: CounterFeature())
            )
        }
    }
}
