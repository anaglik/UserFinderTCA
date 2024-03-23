import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: Int64
    @Attribute(.unique) var login: String
    var name: String
    var publicRepos: Int16
    var followers: Int16
    var avatarURL: URL
    
    init(id: Int64, login: String, name: String, publicRepos: Int16, followers: Int16, avatarURL: URL) {
        self.id = id
        self.login = login
        self.name = name
        self.publicRepos = publicRepos
        self.followers = followers
        self.avatarURL = avatarURL
    }
}
