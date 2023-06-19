import ComposableArchitecture

struct AddContactFeature: ReducerProtocol {
    struct State: Equatable {
        var contact: Contact
    }

    enum Action: Equatable {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setName(String)

        enum Delegate: Equatable {
            case cancel
            case save(Contact)
        }
    }

    @Dependency(\.dismiss) var dismiss

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .cancelButtonTapped:
            return .send(.delegate(.cancel))
        case .saveButtonTapped:
            let contact = state.contact
            return .run { send in
                await send(.delegate(.save(contact)))
                await dismiss()
            }
        case .delegate(.cancel):
            return .run { _ in
                await dismiss()
            }
        case .setName(let name):
            state.contact.name = name
        case .delegate:
            break
        }
        return .none
    }
}

import SwiftUI

struct AddContactView: View {
  let store: StoreOf<AddContactFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        TextField("Name", text: viewStore.binding(get: \.contact.name, send: { .setName($0) }))
        Button("Save") {
          viewStore.send(.saveButtonTapped)
        }
      }
      .toolbar {
        ToolbarItem {
          Button("Cancel") {
            viewStore.send(.cancelButtonTapped)
          }
        }
      }
    }
  }
}

struct AddContactPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AddContactView(
        store: Store(
          initialState: AddContactFeature.State(
            contact: Contact(
              id: UUID(),
              name: "Blob"
            )
          ),
          reducer: AddContactFeature()
        )
      )
    }
  }
}
