import Foundation

func performUIUpdatesOnMan(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
