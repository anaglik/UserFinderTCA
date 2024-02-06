import SwiftUI
import ComposableArchitecture

struct AppView: View {
    var store: Store = Store(initialState: UsersListFeature.State()) {
        UsersListFeature()
    }
    var body: some View {
        if NSClassFromString("XCTestCase") == nil {
            UsersListView(store: store)
        } else {
            Text("Unit tests are running")
        }
    }
}

#Preview {
    let store = Store(initialState: UsersListFeature.State()) {
        UsersListFeature()
    } withDependencies: {
        $0.apiClient.searchUsers = { _ in [] }
    }
    
    return AppView(store: store)
}
