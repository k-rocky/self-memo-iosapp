import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(Error)

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
