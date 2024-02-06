import SwiftUI

struct UserListItemView: View {
    let login: String
    
    var body: some View {
        Text(login).font(.body)
    }
}

#Preview {
    UserListItemView(login: "githubUser")
}
