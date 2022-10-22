import Foundation

enum PageViewState {
    case empty
    case single
    case first
    case center
    case last

    var count: Int {
        switch self {
        case .empty:
            return 0
        case .single:
            return 1
        case .first, .last:
            return 2
        case .center:
            return 3
        }
    }
}
