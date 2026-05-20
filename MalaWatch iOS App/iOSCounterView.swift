import SwiftUI
import UIKit

struct iOSCounterView: View {
    @Environment(MalaStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                themeBackground

                VStack(spacing: 28) {
                    header

                    Button {
                        countBead()
                    } label: {
                        counterFace
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Count bead")

                    progressSummary

                    CounterSettingsPanel(store: store)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
            }
            .navigationTitle("Mala")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.resetCurrentRound()
                        Haptics.play(.light)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .accessibilityLabel("Reset current round")
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(store.counter.label)
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.75)

            Text("Prayer Beads Counter")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 18)
    }

    private var counterFace: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.18), radius: 24, y: 16)

            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 18)
                .padding(14)

            Circle()
                .trim(from: 0, to: store.counter.progress)
                .stroke(progressStyle, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(14)

            VStack(spacing: 6) {
                Text("\(store.counter.currentCount)")
                    .font(.system(size: 76, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Text("/ \(store.counter.beadGoal.rawValue)")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 310)
        .aspectRatio(1, contentMode: .fit)
    }

    private var progressSummary: some View {
        HStack(spacing: 12) {
            StatTile(title: "Rounds", value: "\(store.counter.completedRounds)")
            StatTile(title: "Progress", value: "\(Int(store.counter.progress * 100))%")
        }
    }

    private var themeBackground: some View {
        LinearGradient(
            colors: colors.background,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var progressStyle: LinearGradient {
        LinearGradient(colors: colors.progress, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var colors: ThemeColors {
        ThemeColors(theme: store.counter.theme)
    }

    private func countBead() {
        let event = store.countBead()
        switch event {
        case .countedBead:
            Haptics.play(.light)
        case .completedRound:
            Haptics.notify(.success)
        }
    }
}

private struct CounterSettingsPanel: View {
    @Bindable var store: MalaStore

    var body: some View {
        VStack(spacing: 18) {
            Picker("Goal", selection: $store.counter.beadGoal) {
                ForEach(BeadGoal.allCases) { goal in
                    Text(goal.title).tag(goal)
                }
            }
            .pickerStyle(.segmented)

            TextField("Mantra, prayer, or affirmation", text: $store.counter.label)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

            Picker("Theme", selection: $store.counter.theme) {
                ForEach(MalaTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ThemeColors {
    let background: [Color]
    let progress: [Color]

    init(theme: MalaTheme) {
        switch theme {
        case .sandalwood:
            background = [Color(red: 0.20, green: 0.13, blue: 0.08), Color(red: 0.47, green: 0.29, blue: 0.14)]
            progress = [Color(red: 0.91, green: 0.64, blue: 0.34), Color(red: 0.98, green: 0.84, blue: 0.52)]
        case .jade:
            background = [Color(red: 0.04, green: 0.16, blue: 0.13), Color(red: 0.08, green: 0.36, blue: 0.27)]
            progress = [Color(red: 0.49, green: 0.92, blue: 0.70), Color(red: 0.81, green: 0.99, blue: 0.86)]
        case .obsidian:
            background = [Color(red: 0.02, green: 0.02, blue: 0.03), Color(red: 0.15, green: 0.13, blue: 0.17)]
            progress = [Color(red: 0.82, green: 0.77, blue: 1.0), Color(red: 0.56, green: 0.67, blue: 0.97)]
        case .graphite:
            background = [Color(red: 0.08, green: 0.09, blue: 0.09), Color(red: 0.25, green: 0.27, blue: 0.25)]
            progress = [Color(red: 0.84, green: 0.88, blue: 0.84), Color(red: 0.61, green: 0.69, blue: 0.65)]
        }
    }
}

private enum Haptics {
    static func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

#Preview {
    iOSCounterView()
        .environment(MalaStore())
}
