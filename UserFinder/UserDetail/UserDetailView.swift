import SwiftUI
import ComposableArchitecture

struct UserDetailView: View {
    let store: StoreOf<UserDetailsFeature>
    
    var body: some View {
        Group {
            if let user = store.user {
                userDetailView(for: user)
            } else {
                loadingView
            }
        }
        .navigationTitle(store.login)
        .onAppear {
            store.send(.fetchUserDetails)
        }
        .overlay {
            if store.isErrorPresented {
                ContentUnavailableView("Couldn't fetch content", systemImage: "person.crop.circle.badge.exclamationmark")
            }
        }
    }
    
    @ViewBuilder
    private func userDetailView(for user: UserEntity) -> some View {
        GeometryReader { geometry in
            List {
                Section {
                    ForEach(store.userAttributes, id: \.attributeName) { attribute in
                        HStack {
                            Text(attribute.attributeName)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(attribute.attributeValue)
                                .font(.body)
                        }
                    }
                } header: {
                    let headerHeight = geometry.size.width - (2 * 16) // margins
                    VStack {
                        UserDetailsHeader(imageURL: user.avatarURL, name: user.name, minHeight: headerHeight)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
    }
}

#Preview {
    NavigationStack {
        UserDetailView(store: Store(initialState: UserDetailsFeature.State(login: "octocat")) {
            UserDetailsFeature()
        })
    }
}

