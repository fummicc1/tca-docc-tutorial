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
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }

    enum Action: Equatable {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case timerTick
        case toggleTimerButtonTapped
    }

    enum CancelID {
        case timer
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFactClient

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count -= 1
            state.fact = nil
        case .incrementButtonTapped:
            state.count += 1
            state.fact = nil
        case .factButtonTapped:
            state.fact = nil
            state.isLoading = true

            return .run { [count = state.count] send in
                let fact = try await numberFactClient.fetch(count)
                await send(.factResponse(fact))
            }
        case .factResponse(let fact):
            state.fact = fact
            state.isLoading = false
        case .timerTick:
            state.count += 1
            state.fact = nil
            return .none
        case .toggleTimerButtonTapped:
            state.isTimerRunning.toggle()
            if state.isTimerRunning {
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            } else {
                return .cancel(id: CancelID.timer)
            }
        }
        return .none
    }
}

struct CounterView: View {

    let store: StoreOf<CounterFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer().frame(height: 32)
                Text(String(viewStore.count))
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .buttonStyle(.primary)

                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .buttonStyle(.primary)
                }

                Button(viewStore.isTimerRunning ? "Stop Timer" : "Start Timer") {
                    viewStore.send(.toggleTimerButtonTapped)
                }
                .buttonStyle(.primary)

                Button("Fact") {
                    viewStore.send(.factButtonTapped)
                }
                .buttonStyle(.primary)

                if viewStore.isLoading {
                    ProgressView()
                } else if let fact = viewStore.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.accentColor)
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: some ButtonStyle {
        PrimaryButtonStyle()
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
