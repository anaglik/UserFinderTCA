import SwiftUI

struct UserDetailsHeader: View {
    let imageURL: URL
    let name: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color
                .clear
                .aspectRatio(1.0, contentMode: .fill)
                .overlay {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                }
            HStack {
                Text(name)
                    .font(.headline)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
}

#Preview {
    UserDetailsHeader(imageURL: URL(string: "https://avatars.githubusercontent.com/u/583231?v=4")!,
                      name: "The Octocat")
}
