import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var library: GoldLibrary
    @StateObject private var vm = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    goldHeader
                    searchBar.padding(.horizontal, 18).padding(.bottom, 10)
                    kindPicker.padding(.horizontal, 18).padding(.bottom, 0)

                    switch vm.stage {
                    case .prompt:   filmStripLayout
                    case .loading:  Spacer(); ProgressView().tint(AppTheme.accent); Spacer()
                    case .results(let r): resultList(r)
                    case .empty:
                        Spacer()
                        ContentUnavailableView("No features found", systemImage: "film").padding(40)
                        Spacer()
                    case .error(let m):
                        Spacer()
                        ContentUnavailableView("Projector offline", systemImage: "exclamationmark.triangle",
                            description: Text(m)).padding(40)
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Feature.self) { DetailView(item: $0) }
        }
        .onAppear { vm.preload() }
    }

    private var goldHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("GOLDSCREEN").font(AppTheme.caption(11)).tracking(5).foregroundStyle(AppTheme.accent)
                Text("Programme").font(AppTheme.display(26)).foregroundStyle(AppTheme.label)
            }
            Spacer()
            Image(systemName: "film.fill").font(.system(size: 28)).foregroundStyle(AppTheme.accent)
        }
        .padding(.horizontal, 18).padding(.top, 56).padding(.bottom, 16)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppTheme.accent)
            TextField("", text: $vm.query, prompt: Text("Search the programme…").foregroundStyle(AppTheme.sublabel))
                .font(AppTheme.body(16)).foregroundStyle(AppTheme.label)
                .submitLabel(.search).autocorrectionDisabled()
                .onSubmit { vm.search() }
                .onChange(of: vm.query) { _, _ in vm.search() }
            if !vm.query.isEmpty {
                Button { vm.clear() } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.sublabel)
                }
            }
        }
        .padding(13)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.corner))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.corner).strokeBorder(AppTheme.accent.opacity(0.4)))
    }

    private var kindPicker: some View {
        HStack(spacing: 8) {
            ForEach([MediaKind.film, .series], id: \.self) { k in
                let on = vm.kind == k
                Button { vm.switchKind(k) } label: {
                    Text(k.label).font(AppTheme.caption(13))
                        .foregroundStyle(on ? AppTheme.background : AppTheme.sublabel)
                        .padding(.horizontal, 16).padding(.vertical, 7)
                        .background(on ? AppTheme.accent : AppTheme.surface, in: RoundedRectangle(cornerRadius: 4))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var filmStripLayout: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Text("NOW SHOWING").font(AppTheme.caption(10)).tracking(5)
                    .foregroundStyle(AppTheme.accent).padding(16)

                if vm.featured.isEmpty {
                    ForEach(0..<6, id: \.self) { _ in filmStripSkeleton }
                } else {
                    ForEach(Array(vm.featured.prefix(12).enumerated()), id: \.offset) { i, item in
                        NavigationLink(value: item) {
                            FilmStripPosterRow(item: item, index: i)
                        }.buttonStyle(.plain)
                    }
                }

                Text("END OF PROGRAMME").font(AppTheme.caption(10)).tracking(3)
                    .foregroundStyle(AppTheme.sublabel).padding(16)
            }
            .padding(.bottom, 40)
        }
    }

    private var filmStripSkeleton: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                perforations
                AppTheme.surface.frame(height: 88).frame(maxWidth: .infinity)
                perforations
            }
            Rectangle().fill(Color.black).frame(height: 3)
        }
        .frame(height: 91)
    }

    private var perforations: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2).fill(AppTheme.accent.opacity(0.3))
                    .frame(width: 10, height: 14)
            }
        }
        .frame(width: 26).background(Color.black.opacity(0.9))
    }

    private func resultList(_ items: [Feature]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    NavigationLink(value: item) {
                        HStack(spacing: 14) {
                            Text(String(format: "%02d", i+1))
                                .font(AppTheme.caption(11)).foregroundStyle(AppTheme.accent).frame(width: 24)
                            AsyncImage(url: item.artworkLarge) { img in img.resizable().aspectRatio(contentMode: .fill) }
                                placeholder: { AppTheme.surface }
                                .frame(width: 46, height: 66).clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(AppTheme.accent.opacity(0.3)))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(AppTheme.heading(15)).foregroundStyle(AppTheme.label).lineLimit(2)
                                Text(item.caption).font(AppTheme.caption(12)).foregroundStyle(AppTheme.sublabel)
                                if let s = library.statusOf(id: item.itemID) {
                                    Text(s.label).font(AppTheme.caption(10)).foregroundStyle(AppTheme.accent)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 18).padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    Rectangle().fill(AppTheme.accent.opacity(0.15)).frame(height: 1).padding(.horizontal, 18)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

struct FilmStripPosterRow: View {
    let item: Feature; let index: Int

    var body: some View {
        HStack(spacing: 0) {
            // Left perforations
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2).fill(AppTheme.accent.opacity(0.35)).frame(width: 10, height: 14)
                }
            }
            .frame(width: 26).frame(maxHeight: .infinity).background(Color.black.opacity(0.9))

            // Content
            ZStack(alignment: .leading) {
                AsyncImage(url: item.artworkLarge) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { AppTheme.surface }
                .frame(height: 88).clipped()
                .overlay(LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .leading, endPoint: .trailing))

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("FEATURE \(String(format: "%02d", index + 1))")
                            .font(AppTheme.caption(8)).tracking(3).foregroundStyle(AppTheme.accent.opacity(0.8))
                        Text(item.title).font(AppTheme.heading(15)).foregroundStyle(.white).lineLimit(2)
                        Text(item.caption).font(AppTheme.caption(11)).foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.leading, 12)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity).frame(height: 88)

            // Right perforations
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2).fill(AppTheme.accent.opacity(0.35)).frame(width: 10, height: 14)
                }
            }
            .frame(width: 26).frame(maxHeight: .infinity).background(Color.black.opacity(0.9))
        }
        .frame(height: 88)
        Rectangle().fill(Color.black).frame(height: 3)
    }
}
