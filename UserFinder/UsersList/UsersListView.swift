import SwiftUI
import ComposableArchitecture

struct UsersListView: View {
    @Bindable var store: StoreOf<UsersListFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            resultList
            .navigationTitle("Find Users")
            .searchable(text: $store.searchQuery.sending(\.searchQueryChanged),
                        isPresented: $store.isSearchPresented.sending(\.searchPresentationChanged),
                        prompt: "Find user by login")
            .autocorrectionDisabled()
            .overlay {
                if store.state.isSearchPresented && store.state.isSearchErrorPresented {
                    ContentUnavailableView("Error occurred", systemImage: "person.crop.circle.badge.exclamationmark")
                } else if store.state.isSearchPresented && store.isEmptySearchPresented && !store.searchQuery.isEmpty {
                    ContentUnavailableView.search
                }
            }
        } destination: { store in
            UserDetailView(store: store)
        }
        .task {
            store.send(.loadRecents)
        }
    }
    
    @ViewBuilder
    var resultList: some View {
        if store.isSearchPresented {
            List(store.searchResult) { user in
                NavigationLink(state: UserDetailsFeature.State(login: user.login)) {
                    UserListItemView(login: user.login)
                }
            }
        } else {
            List {
                Section {
                    ForEach(store.recentsResult) { user in
                        NavigationLink(state: UserDetailsFeature.State(login: user.login)) {
                            UserListItemView(login: user.login)
                        }
                    }
                } header: {
                    if !store.recentsResult.isEmpty {
                        Text("Recently Visited")
                    }
                }
            }.overlay {
                if store.recentsResult.isEmpty {
                    ContentUnavailableView("No Recents", systemImage: "person.badge.clock", description: Text("Use search to find users"))
                }
            }
        }
    }
}

#Preview {
    let store = Store(initialState: UsersListFeature.State()) {
        UsersListFeature()
    } withDependencies: {
//        $0.apiClient.searchUsers = { _ in throw GithubClient.Error.wrongURL }
        $0.apiClient.searchUsers = { _  in return [
            SearchItem(id: 97, login: "user97"),
            SearchItem(id: 98, login: "user98"),
            SearchItem(id: 99, login: "user99")
        ]}
    }
    return NavigationStack {
        UsersListView(store: store)
    }
}
