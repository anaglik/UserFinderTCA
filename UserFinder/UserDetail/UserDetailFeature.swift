import Foundation
import ComposableArchitecture

@Reducer
struct UserDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let login: String
        var user: User?
        var isErrorPresented: Bool = false
        
        var userAttributes: [UserAttribute] {
            guard let user else { return [] }
            return [
                .init(attributeName: "Public repos", attributeValue: "\(user.publicRepos)"),
                .init(attributeName: "Followers", attributeValue: "\(user.followers)")
            ]
        }
    }
    enum Action {
        case fetchUserDetails
        case fetchResponse(User)
        case searchErrorPresentationChanged(Bool)
    }
    
    @Dependency(\.usersStore) var usersStore
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchUserDetails:
                let login = state.login
                return .run { send in
                    try await send(.fetchResponse(usersStore.loadDetailsForUser(with: login)))
                } catch: { error, send in
                    print(error)
                    await send(.searchErrorPresentationChanged(true))
                }
            case .fetchResponse(let user):
                state.user = user
                return .none
            case .searchErrorPresentationChanged(let isPresented):
                state.isErrorPresented = isPresented
                return .none
            }
        }
    }
}

extension UserDetailsFeature {
    struct UserAttribute: Equatable {
        let attributeName: String
        let attributeValue: String
    }
}
