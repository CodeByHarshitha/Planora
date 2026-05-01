import Foundation
import SwiftUI

// MARK: - Priority

enum Priority: String, Codable, CaseIterable {
    case low    = "Low"
    case normal = "Normal"
    case high   = "High"

    var dotColor: Color {
        switch self {
        case .low:    return Color(hex: "30D158")
        case .normal: return Color(hex: "5E5CE6")
        case .high:   return Color(hex: "FF3B30")
        }
    }
    var systemImage: String {
        switch self {
        case .low:    return "arrow.down.circle"
        case .normal: return "minus.circle"
        case .high:   return "exclamationmark.circle"
        }
    }
}

// MARK: - TaskCategory

enum TaskCategory: String, Codable, CaseIterable {
    case personal = "Personal"
    case study    = "Study"
    case health   = "Health"
    case work     = "Work"
    case focus    = "Focus"

    var tagBackground: Color {
        switch self {
        case .personal: return Color(hex: "CECBF6")
        case .study:    return Color(hex: "B5D4F4")
        case .health:   return Color(hex: "9FE1CB")
        case .work:     return Color(hex: "F5C4B3")
        case .focus:    return Color(hex: "FAC775")
        }
    }
    var tagForeground: Color {
        switch self {
        case .personal: return Color(hex: "3C3489")
        case .study:    return Color(hex: "0C447C")
        case .health:   return Color(hex: "085041")
        case .work:     return Color(hex: "712B13")
        case .focus:    return Color(hex: "633806")
        }
    }
    var cardBackground: Color {
        switch self {
        case .personal: return Color(hex: "EEEDFE").opacity(0.85)
        case .study:    return Color(hex: "E6F1FB").opacity(0.85)
        case .health:   return Color(hex: "E1F5EE").opacity(0.85)
        case .work:     return Color(hex: "FAECE7").opacity(0.85)
        case .focus:    return Color(hex: "FAEEDA").opacity(0.85)
        }
    }
    var stripeColor: Color {
        switch self {
        case .personal: return Color(hex: "534AB7")
        case .study:    return Color(hex: "378ADD")
        case .health:   return Color(hex: "5DCAA5")
        case .work:     return Color(hex: "F0997B")
        case .focus:    return Color(hex: "EF9F27")
        }
    }
}

// MARK: - Task

struct Task: Identifiable, Codable {
    var id: UUID          = UUID()
    var title: String
    var date: Date        = .now
    var startTime: Date?
    var endTime: Date?
    var priority: Priority      = .normal
    var category: TaskCategory  = .personal
    var isCompleted: Bool       = false

    var hasValidTimeRange: Bool {
        guard let s = startTime, let e = endTime else { return false }
        return s < e
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        startTime: Date? = nil,
        endTime: Date? = nil,
        priority: Priority = .normal,
        category: TaskCategory = .personal,
        isCompleted: Bool = false
    ) {
        self.id = id; self.title = title; self.date = date
        self.startTime = startTime; self.endTime = endTime
        self.priority = priority; self.category = category
        self.isCompleted = isCompleted
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
