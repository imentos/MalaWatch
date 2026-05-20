import SwiftUI
import UIKit

struct iOSCounterView: View {
    @Environment(MalaStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                themeBackground

                VStack(spacing: 20) {
                    header

                    MalaBeadWheel(
                        counter: store.counter,
                        colors: colors,
                        onAdvance: countBead
                    )

                    progressSummary

                    CounterSettingsPanel(store: store)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
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
        .padding(.top, 4)
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

private struct MalaBeadWheel: View {
    let counter: MalaCounter
    let colors: ThemeColors
    let onAdvance: () -> Void

    @GestureState private var dragOffset: CGFloat = 0
    @State private var settlePulse = false

    private let visibleOffsets = Array(-5...5)

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                let size = proxy.size
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let spacing = min(size.height * 0.145, 42)
                let normalizedDrag = dragOffset / spacing

                ZStack {
                    WheelShadow()
                        .fill(.black.opacity(0.18))
                        .frame(width: size.width * 0.34, height: size.height * 0.86)
                        .position(x: center.x + 28, y: center.y + 18)
                        .blur(radius: 18)

                    CordStrand(colors: colors)
                        .frame(width: size.width * 0.22, height: size.height * 0.90)
                        .position(x: center.x + 2, y: center.y)
                        .opacity(0.34)

                    ForEach(visibleOffsets, id: \.self) { offset in
                        let relative = CGFloat(offset) + normalizedDrag
                        let placement = beadPlacement(relative: relative, center: center, spacing: spacing)
                        let beadNumber = wrappedCount(counter.currentCount - offset)

                        RollingBead3D(
                            number: beadNumber,
                            colors: colors,
                            prominence: placement.prominence,
                            isCenter: abs(relative) < 0.35
                        )
                        .frame(width: placement.size, height: placement.size)
                        .position(x: placement.x, y: placement.y)
                        .opacity(placement.opacity)
                        .blur(radius: placement.blur)
                        .zIndex(placement.zIndex)
                    }

                    VStack(spacing: 3) {
                        Text("\(counter.currentCount)")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .monospacedDigit()

                        Text("/ \(counter.beadGoal.rawValue)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.16), radius: 12, y: 8)
                    .position(x: center.x, y: size.height - 28)
                }
            }
            .frame(height: 286)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onTapGesture {
                advance()
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.78), value: counter.currentCount)
            .animation(.interactiveSpring(response: 0.24, dampingFraction: 0.82), value: dragOffset)
            .accessibilityLabel("Mala bead wheel")
            .accessibilityHint("Swipe up to count one bead")
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragOffset) { value, state, _ in
                state = min(max(value.translation.height, -58), 58)
            }
            .onEnded { value in
                if value.translation.height < -18 || value.predictedEndTranslation.height < -42 {
                    advance()
                }
            }
    }

    private func advance() {
        settlePulse.toggle()
        onAdvance()
    }

    private func beadPlacement(relative: CGFloat, center: CGPoint, spacing: CGFloat) -> BeadPlacement {
        let distance = abs(relative)
        let perspective = max(0, 1 - distance * 0.17)
        let prominence = max(0, 1 - distance * 0.24)
        let curve = sin(relative * 0.36)
        let y = center.y + relative * spacing
        let x = center.x + curve * 34
        let size = 72 * max(0.46, perspective)
        let opacity = max(0.18, 1 - distance * 0.15)
        let blur = max(0, distance - 3.2) * 0.7
        let zIndex = 100 - Double(distance * 10)
        return BeadPlacement(x: x, y: y, size: size, opacity: opacity, blur: blur, prominence: prominence, zIndex: zIndex)
    }

    private func wrappedCount(_ rawValue: Int) -> Int {
        let goal = counter.beadGoal.rawValue
        guard goal > 0 else { return 0 }
        let normalized = ((rawValue % goal) + goal) % goal
        return normalized == 0 ? goal : normalized
    }
}

private struct BeadPlacement {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let prominence: CGFloat
    let zIndex: Double
}

private struct RollingBead3D: View {
    let number: Int
    let colors: ThemeColors
    let prominence: CGFloat
    let isCenter: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: beadColors,
                        center: .topLeading,
                        startRadius: 3,
                        endRadius: 58
                    )
                )

            Circle()
                .fill(.white.opacity(0.52 + 0.18 * prominence))
                .frame(width: 18, height: 11)
                .offset(x: 17, y: 13)
                .blur(radius: 1.0)

            Circle()
                .stroke(.white.opacity(0.20), lineWidth: 1.2)

            Circle()
                .stroke(.black.opacity(0.16), lineWidth: 1)
                .padding(7)

            Text("\(number)")
                .font(.system(size: isCenter ? 16 : 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(isCenter ? 0.58 : 0.28))
                .monospacedDigit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isCenter ? 1 : 0.55)
        }
        .shadow(color: .black.opacity(0.22 + 0.12 * prominence), radius: 7 + 9 * prominence, x: 0, y: 4 + 8 * prominence)
        .scaleEffect(isCenter ? 1.08 : 1)
    }

    private var beadColors: [Color] {
        isCenter ? colors.currentBead : colors.bead
    }
}

private struct CordStrand: View {
    let colors: ThemeColors

    var body: some View {
        ZStack {
            Capsule()
                .fill(colors.cord.opacity(0.42))
                .frame(width: 4)

            Capsule()
                .fill(.white.opacity(0.12))
                .frame(width: 1.2)
                .offset(x: 2)
        }
    }
}

private struct WheelShadow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
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
    let bead: [Color]
    let currentBead: [Color]
    let cord: Color

    init(theme: MalaTheme) {
        switch theme {
        case .sandalwood:
            background = [Color(red: 0.82, green: 0.73, blue: 0.62), Color(red: 0.43, green: 0.27, blue: 0.16)]
            bead = [Color(red: 0.95, green: 0.72, blue: 0.43), Color(red: 0.63, green: 0.34, blue: 0.17), Color(red: 0.28, green: 0.13, blue: 0.06)]
            currentBead = [Color(red: 1.0, green: 0.88, blue: 0.56), Color(red: 0.88, green: 0.50, blue: 0.20), Color(red: 0.42, green: 0.18, blue: 0.07)]
            cord = Color(red: 0.29, green: 0.17, blue: 0.11)
        case .jade:
            background = [Color(red: 0.73, green: 0.86, blue: 0.76), Color(red: 0.08, green: 0.30, blue: 0.24)]
            bead = [Color(red: 0.82, green: 1.0, blue: 0.85), Color(red: 0.36, green: 0.72, blue: 0.55), Color(red: 0.10, green: 0.34, blue: 0.27)]
            currentBead = [Color(red: 0.98, green: 1.0, blue: 0.84), Color(red: 0.73, green: 0.90, blue: 0.46), Color(red: 0.25, green: 0.45, blue: 0.22)]
            cord = Color(red: 0.08, green: 0.22, blue: 0.18)
        case .obsidian:
            background = [Color(red: 0.19, green: 0.18, blue: 0.22), Color(red: 0.03, green: 0.03, blue: 0.04)]
            bead = [Color(red: 0.54, green: 0.52, blue: 0.60), Color(red: 0.10, green: 0.10, blue: 0.13), Color.black]
            currentBead = [Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.52, green: 0.45, blue: 0.76), Color(red: 0.10, green: 0.08, blue: 0.18)]
            cord = Color(red: 0.10, green: 0.09, blue: 0.11)
        case .graphite:
            background = [Color(red: 0.70, green: 0.74, blue: 0.72), Color(red: 0.17, green: 0.18, blue: 0.18)]
            bead = [Color(red: 0.86, green: 0.89, blue: 0.86), Color(red: 0.38, green: 0.43, blue: 0.40), Color(red: 0.12, green: 0.14, blue: 0.13)]
            currentBead = [Color(red: 0.98, green: 0.88, blue: 0.60), Color(red: 0.74, green: 0.55, blue: 0.26), Color(red: 0.28, green: 0.20, blue: 0.11)]
            cord = Color(red: 0.18, green: 0.19, blue: 0.18)
        }
    }
}

private enum Haptics {
    @MainActor
    static func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
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
