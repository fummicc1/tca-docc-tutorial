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
            TabView {
                CounterView(
                    store: Store(
                        initialState: CounterFeature.State(),
                        reducer: CounterFeature()
                    )
                )
                .tabItem {
                    Image(systemName: "number")
                    Text("Counter")
                }
                ContactsView(
                    store: Store(
                        initialState: ContactsFeature.State(),
                        reducer: ContactsFeature()
                    )
                )
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Contacts")
                }
            }
        }
    }
}
