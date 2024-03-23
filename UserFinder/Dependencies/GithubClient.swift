import Foundation
import ComposableArchitecture

struct GithubClient {
    var searchUsers: (String) async throws -> [SearchItem]
    var fetchUserDetails: (String) async throws -> NetworkUser
}

extension GithubClient {
    enum Error: Swift.Error {
        case wrongURL
    }
}

extension GithubClient: DependencyKey {
    static let liveValue = Self (
        searchUsers: { query in
            guard let searchRequest = searchUrlRequest(for: query) else { throw Error.wrongURL }
            let (data, _) = try await URLSession.shared.data(for: searchRequest)
            let response =  try JSONDecoder().decode(SearchReponse.self, from: data)
            return response.items.map { SearchItem(id: $0.id, login: $0.login )}
        },
        fetchUserDetails: { login in
            guard let searchRequest = userDetailsRequest(for: login) else { throw Error.wrongURL }
            let (data, _) = try await URLSession.shared.data(for: searchRequest)
            let response =  try JSONDecoder().decode(UserDetailsResponse.self, from: data)
            return NetworkUser(id: response.id,
                               login: response.login,
                               name: response.name ?? response.login,
                               publicRepos: response.publicRepos,
                               followers: response.followers,
                               avatarURL: response.avatarURL)
        }
    )
        
    static let testValue: GithubClient = Self (
        searchUsers: { _ in
            return []
        },
        fetchUserDetails: { _ in
            throw Error.wrongURL
        }
    )
}

extension GithubClient {
    private static func searchUrlRequest(for query: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://api.github.com/search/users") else { return nil }
        components.queryItems = [
            .init(name: "q", value: "\(query) in:login"),
            .init(name: "type", value: "Users")
        ]
        guard let url = components.url else { return nil }
        var request =  URLRequest(url: url)
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private static func userDetailsRequest(for login: String) -> URLRequest? {
        guard let url = URL(string: "https://api.github.com/users/\(login)") else { return nil }
        var request =  URLRequest(url: url)
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
}

extension DependencyValues {
    var apiClient: GithubClient {
        get { self[GithubClient.self] }
        set { self[GithubClient.self] = newValue }
    }
}

private struct SearchReponse: Decodable {
    let items: [SearchItemResponse]
}

private struct SearchItemResponse: Decodable {
    let id: Int64
    let login: String
}

private struct UserDetailsResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case publicRepos = "public_repos"
        case followers
        case avatarURL = "avatar_url"
    }
    let id: Int64
    let login: String
    let name: String?
    let publicRepos: Int
    let followers: Int
    let avatarURL: URL
}
