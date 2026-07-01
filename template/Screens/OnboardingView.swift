import SwiftUI

private struct OnboardingSlide: Identifiable {
    let id = UUID()
    let icon: String
    let headline: String
    let body: String
}

struct OnboardingView: View {
    @EnvironmentObject private var flow: AppFlow
    @State private var current = 0

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(icon: "film.fill", headline: "A premium cinema experience", body: "Browse the complete feature catalogue with the elegance it deserves."),
        OnboardingSlide(icon: "ticket.fill", headline: "Queue your programme", body: "Add features to your personal programme and never miss a screening."),
        OnboardingSlide(icon: "film.stack.fill", headline: "Your archive of taste", body: "Mark films screened, rate with precision, and build your archive."),
        OnboardingSlide(icon: "star.fill", headline: "The gold standard", body: "Your ratings and notes stay with you forever in your golden archive."),
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $current) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                        slidePanel(slide).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: current)

                pageIndicator
                    .padding(.bottom, 20)

                ctaArea
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }

    private func slidePanel(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: slide.icon)
                .font(.system(size: 72))
                .foregroundStyle(AppTheme.accent)
            VStack(spacing: 12) {
                Text(slide.headline)
                    .font(AppTheme.display(26))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.label)
                Text(slide.body)
                    .font(AppTheme.body(16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.sublabel)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { i in
                Capsule()
                    .fill(i == current ? AppTheme.accent : AppTheme.sublabel.opacity(0.3))
                    .frame(width: i == current ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }

    @ViewBuilder
    private var ctaArea: some View {
        if current == slides.count - 1 {
            Button {
                flow.completeOnboarding()
            } label: {
                Text("Enter the Foyer")
                    .font(AppTheme.heading(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent, in: Capsule())
            }
        } else {
            HStack {
                Button("Skip") { flow.completeOnboarding() }
                    .font(AppTheme.body(15))
                    .foregroundStyle(AppTheme.sublabel)
                Spacer()
                Button {
                    withAnimation { current += 1 }
                } label: {
                    Text("Next")
                        .font(AppTheme.heading(15))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.surface, in: Capsule())
                        .overlay(Capsule().strokeBorder(AppTheme.accent.opacity(0.4), lineWidth: 1))
                }
            }
        }
    }
}
