import SwiftUI

struct RootShell: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Programme", systemImage: "film.fill") }
            LibraryView(status: .programme)
                .tabItem { Label("Queue", systemImage: "ticket.fill") }
            LibraryView(status: .archive)
                .tabItem { Label("Archive", systemImage: "film.stack.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(AppTheme.accent)
    }
}
