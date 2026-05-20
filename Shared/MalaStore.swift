import Foundation
import Observation

@Observable
final class MalaStore {
    private let storageKey = "mala.counter.state"
    private let defaults: UserDefaults

    var counter: MalaCounter {
        didSet {
            save()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if
            let data = defaults.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(MalaCounter.self, from: data)
        {
            counter = decoded
        } else {
            counter = MalaCounter()
        }
    }

    func countBead() -> CountEvent {
        counter.increment()
    }

    func setGoal(_ goal: BeadGoal) {
        counter.beadGoal = goal
        counter.adjust(to: counter.currentCount)
    }

    func setLabel(_ label: String) {
        counter.label = label
    }

    func setTheme(_ theme: MalaTheme) {
        counter.theme = theme
    }

    func resetCurrentRound() {
        counter.resetCurrentRound()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(counter) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
