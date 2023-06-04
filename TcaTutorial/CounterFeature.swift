//
//  CounterFeature.swift
//  TcaTutorial
//
//  Created by Fumiya Tanaka on 2023/06/03.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct CounterFeature: ReducerProtocol {
    struct State {
        var count = 0
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count -= 1
            print("decremented")
        case .incrementButtonTapped:
            state.count += 1
            print("incremented")
        }
        print("state.count", state.count)
        return .none
    }
}

struct CounterView: View {

    let store: StoreOf<CounterFeature>

    var body: some View {
        WithViewStore(store, observe: \.count) { viewStore in
            VStack {
                Text(String(viewStore.state))
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)

                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: StoreOf<CounterFeature>(
            initialState: .init(),
            reducer: CounterFeature()._printChanges())
        )
    }
}
