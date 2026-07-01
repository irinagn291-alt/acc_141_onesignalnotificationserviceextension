import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var library: GoldLibrary
    let status: ItemStatus
    var body: some View {
        NavigationStack {
            ZStack { AppTheme.background.ignoresSafeArea()
                let items = library.entries(status: status)
                if items.isEmpty {
                    ContentUnavailableView(status.label, systemImage: status.icon, description: Text("Your \(status.label.lowercased()) is empty."))
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(items) { entry in
                                NavigationLink { DetailView(item: entry.item) } label: { GoldPoster(entry: entry) }.buttonStyle(.plain)
                            }
                        }
                        .padding(18).padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(status.label).navigationBarTitleDisplayMode(.large)
        }
    }
}

struct GoldPoster: View {
    let entry: ScreeningEntry
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: entry.item.artworkLarge) { img in img.resizable().aspectRatio(2/3, contentMode: .fill) }
                placeholder: { AppTheme.surface.aspectRatio(2/3, contentMode: .fit) }
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.corner)
                        .strokeBorder(
                            LinearGradient(colors: [AppTheme.accent, AppTheme.accent.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1.5
                        )
                )
            LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.item.title).font(AppTheme.caption(12)).foregroundStyle(AppTheme.label).lineLimit(2)
                if entry.rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(1...entry.rating, id: \.self) { _ in Text("◆").font(.system(size: 7)).foregroundStyle(AppTheme.accent) }
                    }
                }
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner))
        .shadow(color: AppTheme.accent.opacity(0.15), radius: 10, y: 5)
    }
}
