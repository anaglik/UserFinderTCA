import Foundation

struct NetworkUser: Equatable {
    let id: Int64
    let login: String
    let name: String
    let publicRepos: Int
    let followers: Int
    let avatarURL: URL
}
