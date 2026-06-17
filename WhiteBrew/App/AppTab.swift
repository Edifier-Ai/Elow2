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
        case .today: "Coffee"
        case .records: "Diary"
        case .stats: "Data"
        case .cabinet: "Cabinet"
        case .profile: "Me"
        }
    }

    var symbol: String {
        switch self {
        case .today: "cup.and.saucer.fill"
        case .records: "face.smiling"
        case .stats: "chart.bar.fill"
        case .cabinet: "square.grid.3x3"
        case .profile: "person"
        }
    }
}
