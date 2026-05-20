import Foundation

struct MalaCounter: Codable, Equatable {
    var currentCount: Int
    var completedRounds: Int
    var beadGoal: BeadGoal
    var label: String
    var theme: MalaTheme

    init(
        currentCount: Int = 0,
        completedRounds: Int = 0,
        beadGoal: BeadGoal = .oneHundredEight,
        label: String = "Om Mani Padme Hum",
        theme: MalaTheme = .sandalwood
    ) {
        self.currentCount = currentCount
        self.completedRounds = completedRounds
        self.beadGoal = beadGoal
        self.label = label
        self.theme = theme
    }

    var progress: Double {
        guard beadGoal.rawValue > 0 else { return 0 }
        return Double(currentCount) / Double(beadGoal.rawValue)
    }

    mutating func increment() -> CountEvent {
        currentCount += 1

        if currentCount >= beadGoal.rawValue {
            currentCount = 0
            completedRounds += 1
            return .completedRound
        }

        return .countedBead
    }

    mutating func adjust(to newValue: Int) {
        currentCount = min(max(newValue, 0), beadGoal.rawValue - 1)
    }

    mutating func resetCurrentRound() {
        currentCount = 0
    }
}

enum CountEvent {
    case countedBead
    case completedRound
}

enum BeadGoal: Int, Codable, CaseIterable, Identifiable {
    case twentySeven = 27
    case fiftyFour = 54
    case oneHundredEight = 108

    var id: Int { rawValue }

    var title: String {
        "\(rawValue)"
    }
}

enum MalaTheme: String, Codable, CaseIterable, Identifiable {
    case sandalwood
    case rosewood
    case walnut
    case agarwood
    case jade
    case obsidian
    case graphite

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sandalwood:
            return "Basic Wood"
        case .rosewood:
            return "Rosewood"
        case .walnut:
            return "Walnut"
        case .agarwood:
            return "Agarwood"
        case .jade:
            return "Jade"
        case .obsidian:
            return "Obsidian"
        case .graphite:
            return "Graphite"
        }
    }

    var isPremium: Bool {
        self != .sandalwood
    }

    var materialNote: String {
        switch self {
        case .sandalwood:
            return "Included"
        case .rosewood, .walnut, .agarwood:
            return "Premium wood grain"
        case .jade, .obsidian, .graphite:
            return "Premium material"
        }
    }
}
