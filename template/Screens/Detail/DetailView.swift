import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var library: GoldLibrary
    let item: Feature
    @State private var showNote = false
    @State private var irisOpen = false
    @Environment(\.dismiss) private var dismiss
    private var entry: ScreeningEntry? { library.entries.first { $0.item.itemID == item.itemID } }

    var body: some View {
        ZStack { AppTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    goldPosterSection
                    detailContent.padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 60)
                }
            }
            .opacity(irisOpen ? 1 : 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNote) { NoteSheet(item: item) }
        .onAppear { withAnimation(.easeOut(duration: 0.6).delay(0.1)) { irisOpen = true } }
    }

    private var goldPosterSection: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: item.artworkLarge) { img in img.resizable().aspectRatio(contentMode: .fill) }
                placeholder: { AppTheme.surface }
                .frame(height: 360).clipped()
            LinearGradient(colors: [.clear, AppTheme.background], startPoint: .top, endPoint: .bottom).frame(height: 200)
        }
    }

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(item.title).font(AppTheme.display(26)).foregroundStyle(AppTheme.label)
            Text(item.caption.uppercased()).font(AppTheme.caption(11)).tracking(2).foregroundStyle(AppTheme.accent)

            HStack(spacing: 10) {
                goldButton("Add to Queue", .programme)
                goldButton("Mark Archived", .archive)
            }

            diamondRating

            if let syn = item.synopsis {
                Text(syn).font(AppTheme.body(15)).foregroundStyle(AppTheme.label.opacity(0.8)).lineSpacing(5)
            }

            Button { if entry == nil { library.add(item, status: .programme) }; showNote = true } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("YOUR REVIEW").font(AppTheme.caption(10)).tracking(3).foregroundStyle(AppTheme.accent.opacity(0.7))
                        Text(entry?.note.isEmpty == false ? entry!.note : "Write your critical review…")
                            .font(AppTheme.body(15)).foregroundStyle(entry?.note.isEmpty == false ? AppTheme.label : AppTheme.sublabel).lineLimit(4)
                    }
                    Spacer()
                    Image(systemName: "pencil").foregroundStyle(AppTheme.accent)
                }
                .padding(16).background(AppTheme.surface)
                .overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.3)))
            }.buttonStyle(.plain)
        }
    }

    private func goldButton(_ label: String, _ status: ItemStatus) -> some View {
        Button { library.add(item, status: status) } label: {
            Text(entry?.status == status ? "✓" : label)
                .font(AppTheme.caption(14))
                .foregroundStyle(entry?.status == status ? AppTheme.background : AppTheme.label)
                .frame(maxWidth: .infinity).padding(.vertical, 13)
                .background(entry?.status == status ? AppTheme.accent : AppTheme.surface)
                .overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.4)))
        }
    }

    private var diamondRating: some View {
        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { i in
                Button {
                    if entry == nil { library.add(item, status: .programme) }
                    library.update(id: item.itemID) { $0.rating = i }
                } label: {
                    Text((entry?.rating ?? 0) >= i ? "◆" : "◇")
                        .font(.system(size: 26)).foregroundStyle(AppTheme.accent)
                        .scaleEffect((entry?.rating ?? 0) >= i ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2), value: entry?.rating)
                }
            }
            Spacer()
        }
    }
}

private struct NoteSheet: View {
    @EnvironmentObject private var library: GoldLibrary
    let item: Feature; @State private var text = ""; @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            TextEditor(text: $text).scrollContentBackground(.hidden).background(AppTheme.background).padding()
                .navigationTitle("Critical Review").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { library.update(id: item.itemID) { $0.note = text }; dismiss() }
                    }
                }
        }
        .onAppear { text = library.entries.first { $0.item.itemID == item.itemID }?.note ?? "" }
    }
}
