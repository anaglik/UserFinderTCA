import Foundation
import ComposableArchitecture

@Reducer
struct UsersListFeature {
    @ObservableState
    struct State: Equatable {
        var debounceDuration: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(800)
        var searchQuery = ""
        var isSearchPresented = false
        var isSearchErrorPresented = false
        var isEmptySearchPresented = false
        var searchResult: [SearchItem] = []
        var recentsResult: [UserEntity] = []
        var path = StackState<UserDetailsFeature.State>()
    }
    
    enum Action {
        case loadRecents
        case searchQueryChanged(String)
        case searchPresentationChanged(Bool)
        case searchResponse([SearchItem])
        case recentsResponse([UserEntity])
        case searchErrorPresentationChanged(Bool)
        case path(StackAction<UserDetailsFeature.State, UserDetailsFeature.Action>)
    }
    
    enum CancelID {
        case queryRequest
    }
    
    @Dependency(\.usersStore) var usersStore
    @Dependency(\.mainQueue) var mainQueue
        
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchQueryChanged(let query):
                state.searchQuery = query
                guard !state.searchQuery.isEmpty else {
                    state.searchResult = []
                    state.isSearchErrorPresented = false
                    return .cancel(id: CancelID.queryRequest)
                }
                return .run { send in
                    try await send(.searchResponse(self.usersStore.findUser(with: query)))
                } catch: { error, send in
                    await send(.searchErrorPresentationChanged(true))
                }
                .debounce(id: CancelID.queryRequest,
                           for: state.debounceDuration, scheduler: mainQueue)
            case .searchResponse(let users):
                state.searchResult = users
                state.isSearchErrorPresented = false
                state.isEmptySearchPresented = users.isEmpty
                return .none
            case .path(_):
                return .none
            case .searchPresentationChanged(let isPresented):
                state.isSearchPresented = isPresented
                state.isEmptySearchPresented = false
                if !isPresented {
                    return .run { send in
                        try await send(.recentsResponse(usersStore.loadCachedUsers()))
                    } catch: { error, send in
                        // display error if needed
                    }
                } else {
                    return .none
                }
            case .recentsResponse(let recents):
                state.recentsResult = recents
                return .none
            case .loadRecents:
                return .send(.searchPresentationChanged(false))
            case .searchErrorPresentationChanged(let isPresented):
                state.isSearchErrorPresented = isPresented
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            UserDetailsFeature()
        }
    }
}

