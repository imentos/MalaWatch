import SwiftUI
import UIKit

struct iOSCounterView: View {
    @Environment(MalaStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                themeBackground

                VStack(spacing: 24) {
                    header

                    Button {
                        countBead()
                    } label: {
                        MalaBeadCounter(
                            counter: store.counter,
                            colors: colors
                        )
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

private struct MalaBeadCounter: View {
    let counter: MalaCounter
    let colors: ThemeColors

    private var displayedBeadCount: Int {
        min(counter.beadGoal.rawValue, 36)
    }

    private var activeBeads: Int {
        Int((counter.progress * Double(displayedBeadCount)).rounded(.down))
    }

    private var currentBeadIndex: Int {
        min(activeBeads, displayedBeadCount - 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = side * 0.385
            let beadSize = max(18, side * 0.078)

            ZStack {
                CordRing()
                    .stroke(colors.cord, style: StrokeStyle(lineWidth: beadSize * 0.28, lineCap: .round))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                    .shadow(color: .black.opacity(0.22), radius: 7, y: 5)

                Tassel(colors: colors)
                    .frame(width: side * 0.22, height: side * 0.24)
                    .position(x: center.x, y: center.y + radius + beadSize * 1.2)

                ForEach(0..<displayedBeadCount, id: \.self) { index in
                    let angle = Angle.degrees(-90 + Double(index) / Double(displayedBeadCount) * 360)
                    let x = center.x + cos(angle.radians) * radius
                    let y = center.y + sin(angle.radians) * radius
                    let isCurrent = index == currentBeadIndex && counter.currentCount > 0
                    let isPassed = index < activeBeads
                    let depthScale = 0.9 + 0.16 * ((sin(angle.radians) + 1) / 2)

                    Bead3D(
                        colors: colors,
                        isPassed: isPassed,
                        isCurrent: isCurrent
                    )
                    .frame(width: beadSize * depthScale, height: beadSize * depthScale)
                    .position(x: x, y: y)
                    .zIndex(y)
                }

                VStack(spacing: 5) {
                    Text("\(counter.currentCount)")
                        .font(.system(size: 72, weight: .semibold, design: .rounded))
                        .monospacedDigit()

                    Text("/ \(counter.beadGoal.rawValue)")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(30)
                .background(
                    Circle()
                        .fill(colors.centerMaterial)
                        .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
                )
            }
        }
        .frame(maxWidth: 340)
        .aspectRatio(1, contentMode: .fit)
        .padding(.vertical, 4)
    }
}

private struct Bead3D: View {
    let colors: ThemeColors
    let isPassed: Bool
    let isCurrent: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: beadColors,
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 26
                    )
                )

            Circle()
                .fill(.white.opacity(isCurrent ? 0.62 : 0.34))
                .frame(width: 9, height: 6)
                .offset(x: 8, y: 7)
                .blur(radius: 0.6)

            Circle()
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .scaleEffect(isCurrent ? 1.22 : 1)
        .shadow(color: .black.opacity(isCurrent ? 0.34 : 0.22), radius: isCurrent ? 9 : 5, y: isCurrent ? 6 : 3)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isCurrent)
    }

    private var beadColors: [Color] {
        if isCurrent {
            return colors.currentBead
        }

        return isPassed ? colors.passedBead : colors.bead
    }
}

private struct CordRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

private struct Tassel: View {
    let colors: ThemeColors

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(colors.cord)
                .frame(width: 3)
                .offset(y: -6)

            VStack(spacing: 0) {
                Capsule()
                    .fill(
                        LinearGradient(colors: colors.currentBead, startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 18, height: 22)

                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colors.tassel.opacity(index == 2 ? 1 : 0.78))
                            .frame(width: 4, height: CGFloat(44 - abs(index - 2) * 5))
                    }
                }
            }
            .shadow(color: .black.opacity(0.22), radius: 6, y: 5)
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
    let bead: [Color]
    let passedBead: [Color]
    let currentBead: [Color]
    let cord: Color
    let tassel: Color
    let centerMaterial: AnyShapeStyle

    init(theme: MalaTheme) {
        switch theme {
        case .sandalwood:
            background = [Color(red: 0.82, green: 0.73, blue: 0.62), Color(red: 0.43, green: 0.27, blue: 0.16)]
            bead = [Color(red: 0.95, green: 0.72, blue: 0.43), Color(red: 0.63, green: 0.34, blue: 0.17), Color(red: 0.28, green: 0.13, blue: 0.06)]
            passedBead = [Color(red: 1.0, green: 0.83, blue: 0.53), Color(red: 0.74, green: 0.42, blue: 0.20), Color(red: 0.35, green: 0.17, blue: 0.08)]
            currentBead = [Color(red: 1.0, green: 0.88, blue: 0.56), Color(red: 0.88, green: 0.50, blue: 0.20), Color(red: 0.42, green: 0.18, blue: 0.07)]
            cord = Color(red: 0.29, green: 0.17, blue: 0.11)
            tassel = Color(red: 0.58, green: 0.16, blue: 0.11)
            centerMaterial = AnyShapeStyle(.thinMaterial)
        case .jade:
            background = [Color(red: 0.73, green: 0.86, blue: 0.76), Color(red: 0.08, green: 0.30, blue: 0.24)]
            bead = [Color(red: 0.82, green: 1.0, blue: 0.85), Color(red: 0.36, green: 0.72, blue: 0.55), Color(red: 0.10, green: 0.34, blue: 0.27)]
            passedBead = [Color(red: 0.89, green: 1.0, blue: 0.90), Color(red: 0.45, green: 0.82, blue: 0.61), Color(red: 0.12, green: 0.39, blue: 0.30)]
            currentBead = [Color(red: 0.98, green: 1.0, blue: 0.84), Color(red: 0.73, green: 0.90, blue: 0.46), Color(red: 0.25, green: 0.45, blue: 0.22)]
            cord = Color(red: 0.08, green: 0.22, blue: 0.18)
            tassel = Color(red: 0.88, green: 0.64, blue: 0.22)
            centerMaterial = AnyShapeStyle(.thinMaterial)
        case .obsidian:
            background = [Color(red: 0.19, green: 0.18, blue: 0.22), Color(red: 0.03, green: 0.03, blue: 0.04)]
            bead = [Color(red: 0.54, green: 0.52, blue: 0.60), Color(red: 0.10, green: 0.10, blue: 0.13), Color.black]
            passedBead = [Color(red: 0.78, green: 0.76, blue: 0.88), Color(red: 0.20, green: 0.20, blue: 0.27), Color.black]
            currentBead = [Color(red: 0.92, green: 0.85, blue: 1.0), Color(red: 0.52, green: 0.45, blue: 0.76), Color(red: 0.10, green: 0.08, blue: 0.18)]
            cord = Color(red: 0.10, green: 0.09, blue: 0.11)
            tassel = Color(red: 0.56, green: 0.45, blue: 0.88)
            centerMaterial = AnyShapeStyle(.thinMaterial)
        case .graphite:
            background = [Color(red: 0.70, green: 0.74, blue: 0.72), Color(red: 0.17, green: 0.18, blue: 0.18)]
            bead = [Color(red: 0.86, green: 0.89, blue: 0.86), Color(red: 0.38, green: 0.43, blue: 0.40), Color(red: 0.12, green: 0.14, blue: 0.13)]
            passedBead = [Color(red: 0.95, green: 0.98, blue: 0.94), Color(red: 0.50, green: 0.59, blue: 0.53), Color(red: 0.18, green: 0.21, blue: 0.19)]
            currentBead = [Color(red: 0.98, green: 0.88, blue: 0.60), Color(red: 0.74, green: 0.55, blue: 0.26), Color(red: 0.28, green: 0.20, blue: 0.11)]
            cord = Color(red: 0.18, green: 0.19, blue: 0.18)
            tassel = Color(red: 0.70, green: 0.55, blue: 0.28)
            centerMaterial = AnyShapeStyle(.thinMaterial)
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
