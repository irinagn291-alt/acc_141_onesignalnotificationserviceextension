import SwiftUI
import Charts
import Alamofire

struct ProfileView: View {
    @EnvironmentObject private var library: GoldLibrary
    @State private var animated = false
    @State private var tab: GoldTab = .archive
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        goldBanner
                        goldTabBar
                        switch tab {
                        case .archive: archiveSection
                        case .reviews: reviewsSection
                        }
                    }
                    .padding(18).padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile").navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(contactUsURL: "https://new-goldscreen.pro/contact-us")
            }
            .onAppear { withAnimation(.easeOut(duration: 0.7).delay(0.2)) { animated = true } }
        }
    }

    private var goldBanner: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(red:0.83,green:0.69,blue:0.22).opacity(0.25), AppTheme.background],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("THE GOLDEN ARCHIVE").font(AppTheme.caption(10)).tracking(5).foregroundStyle(AppTheme.accent)
                    Text("\(library.entries(status: .archive).count)").font(.system(size: 52, weight: .bold)).foregroundStyle(AppTheme.accent)
                    Text("features archived").font(AppTheme.body(14)).foregroundStyle(AppTheme.sublabel)
                    HStack(spacing: 20) {
                        goldNum("\(library.entries(status: .programme).count)", "In Programme")
                        goldNum("\(library.entries.filter { $0.starred }.count)", "Loved")
                        goldNum("\(library.entries.filter { !$0.note.isEmpty }.count)", "Reviewed")
                    }
                }
                .padding(20)
                Spacer()
                Text("◆").font(.system(size: 80)).foregroundStyle(AppTheme.accent.opacity(0.15)).padding(10)
            }
        }
        .overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.3)))
    }

    private func goldNum(_ v: String, _ l: String) -> some View {
        VStack(spacing: 2) {
            Text(v).font(AppTheme.heading(20)).foregroundStyle(AppTheme.accent)
            Text(l.uppercased()).font(AppTheme.caption(8)).tracking(2).foregroundStyle(AppTheme.sublabel)
        }
    }

    private var goldTabBar: some View {
        HStack(spacing: 0) {
            ForEach(GoldTab.allCases, id: \.self) { t in
                Button { withAnimation { tab = t } } label: {
                    Text(t.label.uppercased()).font(AppTheme.caption(11)).tracking(2)
                        .foregroundStyle(tab == t ? AppTheme.accent : AppTheme.sublabel)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .overlay(alignment: .bottom) {
                            if tab == t { Rectangle().fill(AppTheme.accent).frame(height: 2) }
                        }
                }
            }
        }
        .background(AppTheme.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(AppTheme.edge).frame(height: 1) }
    }

    @ViewBuilder
    private var archiveSection: some View {
        decadeChart
        genreTable
    }

    private var decadeChart: some View {
        let byDecade: [(String, Int)] = {
            let d = Dictionary(grouping: library.entries(status: .archive).compactMap { e -> Int? in
                guard let y = e.item.year else { return nil }; return (y / 10) * 10
            }, by: { $0 })
            return d.sorted { $0.key < $1.key }.map { ("\($0.key)s", $0.value.count) }
        }()
        return VStack(alignment: .leading, spacing: 14) {
            Text("ARCHIVE BY DECADE").font(AppTheme.caption(10)).tracking(4).foregroundStyle(AppTheme.accent)
            if byDecade.isEmpty {
                Text("Archive more features to see your decade profile.")
                    .font(AppTheme.body(14)).foregroundStyle(AppTheme.sublabel)
            } else {
                Chart(byDecade, id: \.0) { label, count in
                    BarMark(x: .value("Decade", label), y: .value("Features", animated ? count : 0))
                        .foregroundStyle(LinearGradient(colors: [AppTheme.accent, AppTheme.accent.opacity(0.4)],
                                                       startPoint: .top, endPoint: .bottom))
                        .cornerRadius(3)
                }
                .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(AppTheme.sublabel) } }
                .chartYAxis(.hidden)
                .frame(height: 140)
                .animation(.spring(response: 0.8), value: animated)
            }
        }
        .padding(18).background(AppTheme.surface).overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.2)))
    }

    private var genreTable: some View {
        let genres = Dictionary(grouping: library.entries(status: .archive).compactMap(\.item.genre), by: { $0 })
            .sorted { $0.value.count > $1.value.count }.prefix(8)
        return VStack(alignment: .leading, spacing: 0) {
            Text("GENRES").font(AppTheme.caption(10)).tracking(4).foregroundStyle(AppTheme.accent).padding(.bottom, 12)
            ForEach(genres.map { ($0.key, $0.value.count) }, id: \.0) { genre, count in
                HStack {
                    Text(genre).font(AppTheme.body(15)).foregroundStyle(AppTheme.label)
                    Spacer()
                    Text("\(count) feature\(count == 1 ? "" : "s")").font(AppTheme.caption(12)).foregroundStyle(AppTheme.accent)
                }
                .padding(.vertical, 10)
                Rectangle().fill(AppTheme.accent.opacity(0.15)).frame(height: 1)
            }
        }
        .padding(18).background(AppTheme.surface).overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.2)))
    }

    @ViewBuilder
    private var reviewsSection: some View {
        let noted = library.entries.filter { !$0.note.isEmpty }.sorted { $0.addedAt > $1.addedAt }
        if noted.isEmpty {
            VStack(spacing: 14) {
                Text("◇").font(.system(size: 48)).foregroundStyle(AppTheme.accent.opacity(0.3))
                Text("No reviews in the archive.").font(AppTheme.heading(18)).foregroundStyle(AppTheme.label)
                Text("Write your critical review after each feature.").font(AppTheme.body(14)).foregroundStyle(AppTheme.sublabel).multilineTextAlignment(.center)
            }.padding(32)
        } else {
            VStack(spacing: 16) {
                ForEach(noted) { e in GoldReviewCard(entry: e) }
            }
        }
    }
}

enum GoldTab: CaseIterable {
    case archive, reviews
    var label: String { self == .archive ? "Archive" : "Reviews" }
}

struct GoldReviewCard: View {
    let entry: ScreeningEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                AsyncImage(url: entry.item.artworkLarge) { img in img.resizable().aspectRatio(contentMode: .fill) }
                    placeholder: { AppTheme.surface }
                    .frame(width: 46, height: 66).clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(AppTheme.accent.opacity(0.4)))
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.item.title).font(AppTheme.heading(14)).foregroundStyle(AppTheme.label).lineLimit(2)
                    Text(entry.item.caption.uppercased()).font(AppTheme.caption(9)).tracking(2).foregroundStyle(AppTheme.sublabel)
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { i in Text(i <= entry.rating ? "◆" : "◇").font(.system(size: 10)).foregroundStyle(AppTheme.accent) }
                    }
                }
                Spacer()
                Text(entry.addedAt, format: .dateTime.day().month(.abbreviated)).font(AppTheme.caption(10)).foregroundStyle(AppTheme.sublabel)
            }
            Text(entry.note).font(AppTheme.body(14)).foregroundStyle(AppTheme.label.opacity(0.85)).lineSpacing(5).lineLimit(6)
                .padding(12).background(AppTheme.accent.opacity(0.05))
                .overlay(alignment: .leading) { Rectangle().fill(AppTheme.accent).frame(width: 2) }
        }
        .padding(16).background(AppTheme.surface).overlay(Rectangle().strokeBorder(AppTheme.accent.opacity(0.2)))
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let contactUsURL: String
    @State private var showContactUs = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                List {
                    Section {
                        Button {
                            showContactUs = true
                        } label: {
                            HStack {
                                Label("Contact Us", systemImage: "envelope.fill")
                                    .foregroundColor(AppTheme.label)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.sublabel)
                            }
                        }
                    } header: {
                        Text("Support")
                            .foregroundColor(AppTheme.sublabel)
                    }
                    .listRowBackground(AppTheme.surface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
            .sheet(isPresented: $showContactUs) {
                NavigationStack {
                    Alamofire.WebContentView(url: contactUsURL)
                        .navigationTitle("Contact Us")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showContactUs = false
                                }
                                .foregroundColor(AppTheme.accent)
                            }
                        }
                }
            }
        }
    }
}
