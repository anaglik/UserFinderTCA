import Foundation
import SwiftData
import ComposableArchitecture

@ModelActor
actor UsersFetcher {
    func fetchAllUsers() throws -> [User] {
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor)
    }
    
    func fetchUser(with login: String) throws -> User? {
        let predicate = #Predicate<User> { $0.login == login }
        var descriptor = FetchDescriptor<User>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    func saveLocalUser(from networkUser: NetworkUser) throws -> User {
        let user = User.newUser(from: networkUser)
        modelContext.insert(user)
        try modelContext.save()
        return user
    }
}

private extension User {
    static func newUser(from networkUser: NetworkUser) -> User {
        let user = User(id: networkUser.id,
                        login: networkUser.login,
                        name: networkUser.name,
                        publicRepos: Int16(networkUser.publicRepos),
                        followers: Int16(networkUser.followers),
                        avatarURL: networkUser.avatarURL)
        return user
    }
}

extension UsersFetcher: DependencyKey {
    static var liveValue: UsersFetcher {
        let container = try! ModelContainer(for: User.self)
        return UsersFetcher(modelContainer: container)
    }
    static var testValue: UsersFetcher {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: configuration)
        return UsersFetcher(modelContainer: container)
    }
}

extension DependencyValues {
  var usersFetcher: UsersFetcher {
    get { self[UsersFetcher.self] }
    set { self[UsersFetcher.self] = newValue }
  }
}
