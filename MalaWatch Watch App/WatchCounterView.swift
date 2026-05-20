import SwiftUI
import WatchKit

struct WatchCounterView: View {
    @Environment(MalaStore.self) private var store
    @State private var crownValue = 0.0
    @State private var showingStylePicker = false

    var body: some View {
        @Bindable var store = store

        ZStack {
            themeBackground

            VStack(spacing: 4) {
                WatchMalaBeads(counter: store.counter, colors: colors)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: 8) {
                    Text("\(max(store.counter.currentCount, 1))/\(store.counter.beadGoal.rawValue)")
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.82))

                    Circle()
                        .fill(.white.opacity(0.28))
                        .frame(width: 3, height: 3)

                    Text("R \(store.counter.completedRounds)")
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.60))
                }
                .padding(.bottom, 2)
            }
            .padding(.horizontal, 8)
            .padding(.top, 24)

            VStack {
                HStack {
                    WatchIconButton(systemName: "arrow.counterclockwise") {
                        store.resetCurrentRound()
                        crownValue = 0
                        WKInterfaceDevice.current().play(.click)
                    }
                    .accessibilityLabel("Reset")

                    Spacer()

                    WatchIconButton(systemName: "paintpalette") {
                        showingStylePicker = true
                        WKInterfaceDevice.current().play(.click)
                    }
                    .accessibilityLabel("Skin")
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)

                Spacer()
            }
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
        .onLongPressGesture {
            showingStylePicker = true
            WKInterfaceDevice.current().play(.click)
        }
        .sheet(isPresented: $showingStylePicker) {
            WatchStylePickerView(store: store)
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

private struct WatchIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(.black.opacity(0.30), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 0.8))
        }
        .buttonStyle(.plain)
    }
}

private struct WatchMalaBeads: View {
    let counter: MalaCounter
    let colors: ThemeColors

    private let visibleOffsets = Array(-4...4)

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = CGPoint(x: size.width / 2, y: size.height * 0.48)
            let spacing = min(size.height * 0.118, 20)
            let displayCount = max(counter.currentCount, 1)

            ZStack {
                Capsule()
                    .fill(.black.opacity(0.18))
                    .frame(width: size.width * 0.26, height: size.height * 0.72)
                    .position(x: center.x + 14, y: center.y + 8)
                    .blur(radius: 12)

                ForEach(visibleOffsets, id: \.self) { offset in
                    let relative = CGFloat(offset)
                    let placement = beadPlacement(relative: relative, center: center, spacing: spacing)
                    let number = wrappedCount(displayCount - offset)

                    WatchBead3D(
                        number: number,
                        colors: colors,
                        prominence: placement.prominence,
                        isCenter: offset == 0
                    )
                    .frame(width: placement.size, height: placement.size)
                    .position(x: placement.x, y: placement.y)
                    .opacity(placement.opacity)
                    .blur(radius: placement.blur)
                    .zIndex(placement.zIndex)
                }

                if let startOffset = startBeadOffset(displayCount: displayCount) {
                    let placement = beadPlacement(relative: CGFloat(startOffset), center: center, spacing: spacing)
                    WatchGuruBead()
                        .frame(width: 18, height: 18)
                        .position(x: placement.x - placement.size * 0.20, y: placement.y - placement.size * 0.54)
                        .opacity(placement.opacity)
                        .zIndex(placement.zIndex + 1)
                }
            }
        }
        .accessibilityLabel("Mala beads")
    }

    private func beadPlacement(relative: CGFloat, center: CGPoint, spacing: CGFloat) -> WatchBeadPlacement {
        let distance = abs(relative)
        let perspective = max(0, 1 - distance * 0.14)
        let prominence = max(0, 1 - distance * 0.22)
        let curve = sin(relative * 0.42)
        let y = center.y + relative * spacing
        let x = center.x + curve * 17
        let size = 50 * max(0.48, perspective)
        let opacity = max(0.22, 1 - distance * 0.13)
        let blur = max(0, distance - 3.0) * 0.35
        let zIndex = 100 - Double(distance * 10)
        return WatchBeadPlacement(x: x, y: y, size: size, opacity: opacity, blur: blur, prominence: prominence, zIndex: zIndex)
    }

    private func wrappedCount(_ rawValue: Int) -> Int {
        let goal = counter.beadGoal.rawValue
        guard goal > 0 else { return 0 }
        let normalized = ((rawValue % goal) + goal) % goal
        return normalized == 0 ? goal : normalized
    }

    private func startBeadOffset(displayCount: Int) -> Int? {
        visibleOffsets.first { offset in
            wrappedCount(displayCount - offset) == 1
        }
    }
}

private struct WatchBeadPlacement {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let prominence: CGFloat
    let zIndex: Double
}

private struct WatchBead3D: View {
    let number: Int
    let colors: ThemeColors
    let prominence: CGFloat
    let isCenter: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: isCenter ? colors.currentBead : colors.bead,
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 38
                    )
                )

            Circle()
                .fill(.white.opacity(0.48 + 0.16 * prominence))
                .frame(width: isCenter ? 12 : 9, height: isCenter ? 8 : 6)
                .offset(x: isCenter ? 12 : 9, y: isCenter ? 9 : 7)
                .blur(radius: 0.8)

            Circle()
                .stroke(.white.opacity(0.20), lineWidth: 0.8)

            Circle()
                .stroke(.black.opacity(0.17), lineWidth: 0.8)
                .padding(isCenter ? 5 : 4)

            Text("\(number)")
                .font(.system(size: isCenter ? 13 : 8, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(isCenter ? 0.56 : 0.22))
                .monospacedDigit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isCenter ? 1 : 0.5)
        }
        .shadow(color: .black.opacity(0.22 + 0.10 * prominence), radius: 5 + 7 * prominence, x: 0, y: 3 + 5 * prominence)
        .scaleEffect(isCenter ? 1.08 : 1)
    }
}

private struct WatchGuruBead: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.38, blue: 0.28),
                            Color(red: 0.70, green: 0.08, blue: 0.04),
                            Color(red: 0.30, green: 0.02, blue: 0.01)
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 18
                    )
                )

            Circle()
                .fill(.white.opacity(0.60))
                .frame(width: 5, height: 4)
                .offset(x: 5, y: 5)
                .blur(radius: 0.4)

            Circle().stroke(.white.opacity(0.22), lineWidth: 0.7)
        }
    }
}

private struct WatchStylePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: MalaStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(MalaTheme.allCases) { theme in
                    Button {
                        store.counter.theme = theme
                        WKInterfaceDevice.current().play(.click)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            WatchThemeSwatch(theme: theme)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(theme.title)
                                    .font(.caption.weight(.semibold))
                                Text(theme.materialNote)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if store.counter.theme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Skin")
        }
    }
}

private struct WatchThemeSwatch: View {
    let theme: MalaTheme

    var body: some View {
        let colors = ThemeColors(theme: theme)
        Circle()
            .fill(
                RadialGradient(
                    colors: colors.currentBead,
                    center: .topLeading,
                    startRadius: 1,
                    endRadius: 18
                )
            )
            .frame(width: 24, height: 24)
            .overlay(Circle().stroke(.white.opacity(0.28), lineWidth: 0.8))
    }
}

private struct ThemeColors {
    let background: [Color]
    let progress: [Color]
    let bead: [Color]
    let currentBead: [Color]

    init(theme: MalaTheme) {
        switch theme {
        case .sandalwood:
            background = [Color(red: 0.14, green: 0.10, blue: 0.07), Color(red: 0.29, green: 0.18, blue: 0.10)]
            progress = [Color(red: 0.83, green: 0.55, blue: 0.28), Color(red: 0.96, green: 0.78, blue: 0.45)]
            bead = [Color(red: 0.95, green: 0.72, blue: 0.43), Color(red: 0.63, green: 0.34, blue: 0.17), Color(red: 0.28, green: 0.13, blue: 0.06)]
            currentBead = [Color(red: 1.0, green: 0.88, blue: 0.56), Color(red: 0.88, green: 0.50, blue: 0.20), Color(red: 0.42, green: 0.18, blue: 0.07)]
        case .rosewood:
            background = [Color(red: 0.16, green: 0.06, blue: 0.05), Color(red: 0.34, green: 0.12, blue: 0.08)]
            progress = [Color(red: 0.78, green: 0.20, blue: 0.12), Color(red: 1.0, green: 0.52, blue: 0.34)]
            bead = [Color(red: 0.92, green: 0.49, blue: 0.32), Color(red: 0.55, green: 0.16, blue: 0.11), Color(red: 0.20, green: 0.05, blue: 0.04)]
            currentBead = [Color(red: 1.0, green: 0.64, blue: 0.42), Color(red: 0.72, green: 0.22, blue: 0.13), Color(red: 0.27, green: 0.06, blue: 0.04)]
        case .walnut:
            background = [Color(red: 0.12, green: 0.08, blue: 0.05), Color(red: 0.28, green: 0.18, blue: 0.10)]
            progress = [Color(red: 0.65, green: 0.38, blue: 0.17), Color(red: 0.95, green: 0.70, blue: 0.42)]
            bead = [Color(red: 0.77, green: 0.52, blue: 0.31), Color(red: 0.42, green: 0.25, blue: 0.13), Color(red: 0.15, green: 0.08, blue: 0.04)]
            currentBead = [Color(red: 0.96, green: 0.72, blue: 0.44), Color(red: 0.58, green: 0.33, blue: 0.15), Color(red: 0.22, green: 0.11, blue: 0.05)]
        case .agarwood:
            background = [Color(red: 0.06, green: 0.05, blue: 0.04), Color(red: 0.20, green: 0.15, blue: 0.10)]
            progress = [Color(red: 0.50, green: 0.36, blue: 0.20), Color(red: 0.86, green: 0.74, blue: 0.52)]
            bead = [Color(red: 0.64, green: 0.51, blue: 0.36), Color(red: 0.30, green: 0.21, blue: 0.13), Color(red: 0.08, green: 0.06, blue: 0.04)]
            currentBead = [Color(red: 0.88, green: 0.75, blue: 0.53), Color(red: 0.42, green: 0.29, blue: 0.16), Color(red: 0.13, green: 0.09, blue: 0.06)]
        case .jade:
            background = [Color(red: 0.04, green: 0.12, blue: 0.10), Color(red: 0.06, green: 0.24, blue: 0.18)]
            progress = [Color(red: 0.47, green: 0.89, blue: 0.68), Color(red: 0.77, green: 0.98, blue: 0.84)]
            bead = [Color(red: 0.82, green: 1.0, blue: 0.85), Color(red: 0.36, green: 0.72, blue: 0.55), Color(red: 0.10, green: 0.34, blue: 0.27)]
            currentBead = [Color(red: 0.98, green: 1.0, blue: 0.84), Color(red: 0.73, green: 0.90, blue: 0.46), Color(red: 0.25, green: 0.45, blue: 0.22)]
        case .obsidian:
            background = [Color(red: 0.02, green: 0.02, blue: 0.03), Color(red: 0.10, green: 0.09, blue: 0.11)]
            progress = [Color(red: 0.82, green: 0.77, blue: 1.0), Color(red: 0.55, green: 0.66, blue: 0.95)]
            bead = [Color(red: 0.54, green: 0.52, blue: 0.60), Color(red: 0.10, green: 0.10, blue: 0.13), Color.black]
            currentBead = [Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.52, green: 0.45, blue: 0.76), Color(red: 0.10, green: 0.08, blue: 0.18)]
        case .graphite:
            background = [Color(red: 0.08, green: 0.09, blue: 0.09), Color(red: 0.17, green: 0.18, blue: 0.17)]
            progress = [Color(red: 0.80, green: 0.84, blue: 0.80), Color(red: 0.58, green: 0.65, blue: 0.61)]
            bead = [Color(red: 0.86, green: 0.89, blue: 0.86), Color(red: 0.38, green: 0.43, blue: 0.40), Color(red: 0.12, green: 0.14, blue: 0.13)]
            currentBead = [Color(red: 0.98, green: 0.88, blue: 0.60), Color(red: 0.74, green: 0.55, blue: 0.26), Color(red: 0.28, green: 0.20, blue: 0.11)]
        }
    }
}

#Preview {
    WatchCounterView()
        .environment(MalaStore())
}
