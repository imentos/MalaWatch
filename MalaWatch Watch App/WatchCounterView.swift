import SwiftUI
import WatchKit

struct WatchCounterView: View {
    @Environment(MalaStore.self) private var store
    @State private var crownValue = 0.0

    var body: some View {
        @Bindable var store = store

        ZStack {
            themeBackground

            VStack(spacing: 8) {
                Text(store.counter.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: store.counter.progress)
                        .stroke(progressStyle, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(store.counter.currentCount)")
                            .font(.system(size: 44, weight: .semibold, design: .rounded))
                            .monospacedDigit()

                        Text("/ \(store.counter.beadGoal.rawValue)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 132, height: 132)

                Text("Rounds \(store.counter.completedRounds)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
        .focusable()
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Double(store.counter.beadGoal.rawValue - 1),
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            store.counter.adjust(to: Int(newValue.rounded()))
        }
        .onTapGesture {
            let event = store.countBead()
            crownValue = Double(store.counter.currentCount)
            playHaptic(for: event)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    store.resetCurrentRound()
                    crownValue = 0
                    WKInterfaceDevice.current().play(.click)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.plain)
            }
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

    private func playHaptic(for event: CountEvent) {
        switch event {
        case .countedBead:
            WKInterfaceDevice.current().play(.click)
        case .completedRound:
            WKInterfaceDevice.current().play(.success)
        }
    }
}

private struct ThemeColors {
    let background: [Color]
    let progress: [Color]

    init(theme: MalaTheme) {
        switch theme {
        case .sandalwood:
            background = [Color(red: 0.14, green: 0.10, blue: 0.07), Color(red: 0.29, green: 0.18, blue: 0.10)]
            progress = [Color(red: 0.83, green: 0.55, blue: 0.28), Color(red: 0.96, green: 0.78, blue: 0.45)]
        case .jade:
            background = [Color(red: 0.04, green: 0.12, blue: 0.10), Color(red: 0.06, green: 0.24, blue: 0.18)]
            progress = [Color(red: 0.47, green: 0.89, blue: 0.68), Color(red: 0.77, green: 0.98, blue: 0.84)]
        case .obsidian:
            background = [Color(red: 0.02, green: 0.02, blue: 0.03), Color(red: 0.10, green: 0.09, blue: 0.11)]
            progress = [Color(red: 0.82, green: 0.77, blue: 1.0), Color(red: 0.55, green: 0.66, blue: 0.95)]
        case .graphite:
            background = [Color(red: 0.08, green: 0.09, blue: 0.09), Color(red: 0.17, green: 0.18, blue: 0.17)]
            progress = [Color(red: 0.80, green: 0.84, blue: 0.80), Color(red: 0.58, green: 0.65, blue: 0.61)]
        }
    }
}

#Preview {
    WatchCounterView()
        .environment(MalaStore())
}
