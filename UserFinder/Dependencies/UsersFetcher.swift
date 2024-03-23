import Foundation
import SwiftData
import ComposableArchitecture

struct UsersFetcher {
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func fetchAllUsers() throws -> [User] {
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.name)])
        return try container.mainContext.fetch(descriptor)
    }
    @MainActor
    func fetchUser(with login: String) throws -> User? {
        let predicate = #Predicate<User> { $0.login == login }
        var descriptor = FetchDescriptor<User>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try container.mainContext.fetch(descriptor).first
    }
    @MainActor
    func saveLocalUser(from networkUser: NetworkUser) throws -> User {
        let user = User.newUser(from: networkUser)
        container.mainContext.insert(user)
        try container.mainContext.save()
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
    static var liveValue: Self {
        let container = try! ModelContainer(for: User.self)
        return UsersFetcher(container: container)
    }
    static var testValue: Self {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: configuration)
        return UsersFetcher(container: container)
    }
}

extension DependencyValues {
  var usersFetcher: UsersFetcher {
    get { self[UsersFetcher.self] }
    set { self[UsersFetcher.self] = newValue }
  }
}
