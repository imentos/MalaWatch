import AVFoundation
import SwiftUI
import UIKit

private let chantSyllables = ["Om", "Ma", "Ni", "Pad", "Me", "Hum"]
private let chantPronunciations = ["Ohm", "Mah", "Nee", "Pahd", "May", "Hoom"]

private enum ChantVoiceMode: String, CaseIterable, Identifiable {
    case follow
    case silent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .follow:
            return "Follow"
        case .silent:
            return "Silent"
        }
    }
}

struct iOSCounterView: View {
    @Environment(MalaStore.self) private var store
    @AppStorage("mala.chant.voiceMode") private var chantVoiceMode = ChantVoiceMode.follow.rawValue
    @State private var spokenSyllableIndex = 0
    @State private var chantPulse = false
    @State private var chantSpeaker = ChantSpeaker()

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topTrailing) {
                themeBackground
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .ignoresSafeArea(.all)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ChantGuide(
                            syllables: chantSyllables,
                            currentIndex: spokenSyllableIndex,
                            pulse: chantPulse
                        )

                        MalaBeadWheel(
                            counter: store.counter,
                            colors: colors,
                            onAdvance: countBead
                        )

                        progressSummary

                        CounterSettingsPanel(
                            store: store,
                            chantVoiceMode: $chantVoiceMode
                        )
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, proxy.safeAreaInsets.top + 12)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + 18)
                    .frame(maxWidth: .infinity)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(themeBackground.ignoresSafeArea(.all))
                .scrollBounceBehavior(.basedOnSize)

                Button {
                    store.resetCurrentRound()
                    Haptics.play(.light)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 60, height: 60)
                        .background(.regularMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
                }
                .accessibilityLabel("Reset current round")
                .padding(.top, proxy.safeAreaInsets.top + 8)
                .padding(.trailing, 18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(themeBackground.ignoresSafeArea(.all))
        }
        .background(themeBackground.ignoresSafeArea(.all))
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
        let nextSyllableIndex = chantIndex(forCount: store.counter.currentCount + 1)
        let event = store.countBead()

        withAnimation(.spring(response: 0.24, dampingFraction: 0.56)) {
            spokenSyllableIndex = nextSyllableIndex
            chantPulse.toggle()
        }
        if chantVoiceMode == ChantVoiceMode.follow.rawValue {
            chantSpeaker.speak(chantPronunciations[nextSyllableIndex])
        }

        switch event {
        case .countedBead:
            Haptics.play(.light)
        case .completedRound:
            Haptics.notify(.success)
        }
    }

    private func chantIndex(forCount count: Int) -> Int {
        let normalized = max(count - 1, 0)
        return normalized % chantSyllables.count
    }
}


private struct ChantGuide: View {
    let syllables: [String]
    let currentIndex: Int
    let pulse: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text(syllables[currentIndex])
                .font(.system(size: 52, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.86))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .scaleEffect(pulse ? 1.08 : 1)
                .shadow(color: .white.opacity(0.24), radius: 10, y: 3)

            HStack(spacing: 6) {
                ForEach(syllables.indices, id: \.self) { index in
                    Text(syllables[index])
                        .font(.system(size: 13, weight: index == currentIndex ? .semibold : .medium, design: .rounded))
                        .foregroundStyle(index == currentIndex ? .black.opacity(0.84) : .black.opacity(0.42))
                        .frame(minWidth: 42)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(index == currentIndex ? .white.opacity(0.55) : .white.opacity(0.16))
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current chant syllable, \(syllables[currentIndex])")
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
                }
            }
            .frame(height: 286)
            .clipped()
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

private struct WheelShadow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

private struct CounterSettingsPanel: View {
    @Bindable var store: MalaStore
    @Binding var chantVoiceMode: String

    var body: some View {
        VStack(spacing: 18) {
            Picker("Voice", selection: $chantVoiceMode) {
                ForEach(ChantVoiceMode.allCases) { mode in
                    Text(mode.title).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)

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


@MainActor
private final class ChantSpeaker {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ syllable: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: syllable)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.38
        utterance.pitchMultiplier = 0.96
        utterance.volume = 0.85
        synthesizer.speak(utterance)
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
