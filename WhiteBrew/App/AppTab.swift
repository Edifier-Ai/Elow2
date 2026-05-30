import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case records
    case stats
    case cabinet
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .records: "Record"
        case .stats: "Stats"
        case .cabinet: "Cabinet"
        case .profile: "Me"
        }
    }

    var symbol: String {
        switch self {
        case .today: "cup.and.saucer"
        case .records: "calendar"
        case .stats: "chart.bar"
        case .cabinet: "square.grid.3x3"
        case .profile: "person"
        }
    }
}
