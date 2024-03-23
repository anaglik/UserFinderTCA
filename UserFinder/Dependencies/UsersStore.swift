import Foundation
import ComposableArchitecture

final class UsersStore {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.usersFetcher) var usersFetcher
        
    func findUser(with login: String) async throws -> [SearchItem] {
        return try await apiClient.searchUsers(login)
    }
    
    func loadDetailsForUser(with login: String) async throws -> User {
        if let cachedUser = try await usersFetcher.fetchUser(with: login) {
            return cachedUser
        } else {
            let networkUser = try await apiClient.fetchUserDetails(login)
            let user = try await usersFetcher.saveLocalUser(from: networkUser)
            return user
        }
    }
    
    func loadCachedUsers() async throws -> [User] {
        let users = try await usersFetcher.fetchAllUsers()
        return users
    }
}

extension UsersStore {
    enum Error: Swift.Error {
        case couldNotFetchUser
        case persistanceError
    }
}

extension UsersStore: DependencyKey {
    static let liveValue: UsersStore = UsersStore()
    static let testValue: UsersStore = UsersStore()
}

extension DependencyValues {
    var usersStore: UsersStore {
        get { self[UsersStore.self] }
        set { self[UsersStore.self] = newValue }
    }
}
