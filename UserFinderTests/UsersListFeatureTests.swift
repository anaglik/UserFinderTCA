import ComposableArchitecture
import XCTest
@testable import UserFinder

@MainActor
final class UsersListFeatureTests: XCTestCase {
    
    func testThatItLoadsSearchResultsOnlyAfterDebounce() async {
        let exampleSearchResults = [SearchItem(id: 989, login: "octocat")]
        let testQueue = DispatchQueue.test
        let debouceDuration = DispatchQueue.SchedulerTimeType.Stride.seconds(1)
        let store = TestStore(initialState: UsersListFeature.State(debounceDuration: debouceDuration)) {
            UsersListFeature()
        } withDependencies: {
            $0.apiClient.searchUsers = { query in
                XCTAssertEqual(query, "octocat")
                return exampleSearchResults
            }
            $0.mainQueue = testQueue.eraseToAnyScheduler()
        }
        
        await store.send(.searchQueryChanged("octo")) {
            $0.searchQuery = "octo"
            $0.searchResult = []
            $0.isSearchErrorPresented = false
        }
        await testQueue.advance(by: .milliseconds(500))
        await store.send(.searchQueryChanged("octocat")) {
            $0.searchQuery = "octocat"
            $0.searchResult = []
            $0.isSearchErrorPresented = false
        }
        await testQueue.advance(by: debouceDuration)
        await store.receive(\.searchResponse) {
            $0.searchResult = exampleSearchResults
            $0.isSearchErrorPresented = false
        }
    }
}
