import ComposableArchitecture
import XCTest
@testable import TcaTutorial

@MainActor
final class CounterFeatureTests: XCTestCase {

    typealias CounterTestStore = TestStore<CounterFeature.State, CounterFeature.Action, CounterFeature.State, CounterFeature.Action, ()>

    let testClock: TestClock = TestClock()

    var initialStore: CounterTestStore {
        TestStore(
            initialState: CounterFeature.State(),
            reducer: { CounterFeature() },
            withDependencies: {
                $0.continuousClock = testClock
                $0.numberFact.fetch = {
                    "\($0) is a good number!"
                }
            }
        )
    }

    func testCounter() async {
        let store = initialStore

        await store.send(.incrementButtonTapped) {
            // rather than `count += 1`, should use absolute assertion such as `count = 1`.
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    func testTimer() async {
        let store = initialStore

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        await testClock.advance(by: .seconds(1))
        await store.receive(.timerTick) {
            $0.count = 1
        }
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }

    func testNumberFact() async {
        let store = initialStore
        let expected = "0 is a good number!"

        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(.factResponse(expected)) {
            $0.isLoading = false
            $0.fact = expected
        }
    }
}
