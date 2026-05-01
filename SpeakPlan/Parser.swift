import Foundation

// MARK: - Natural Language Parser

func parseInput(_ input: String) -> [Task] {
    let parts = input
        .replacingOccurrences(of: " and ", with: ",", options: .caseInsensitive)
        .components(separatedBy: CharacterSet(charactersIn: ",\n"))

    return parts.compactMap { part -> Task? in
        let trimmed = part.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let lower = trimmed.lowercased()

        let date      = extractDate(from: lower)
        let startTime = extractTime(from: lower)
        let duration  = extractDuration(from: lower)
        let endTime: Date? = {
            guard let s = startTime, let d = duration else { return nil }
            return Calendar.current.date(byAdding: .minute, value: d, to: s)
        }()

        return Task(
            title:     cleanTitle(trimmed),
            date:      date,
            startTime: startTime,
            endTime:   endTime,
            priority:  extractPriority(from: lower),
            category:  extractCategory(from: lower)
        )
    }
}

// MARK: - Helpers

private func extractDate(from text: String) -> Date {
    if text.contains("tomorrow") {
        return Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    }
    return .now
}

private func extractTime(from text: String) -> Date? {
    let pattern = #"(\d{1,2})(:(\d{2}))?\s*(am|pm)?"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
    let nsText = text as NSString
    let range  = NSRange(text.startIndex..., in: text)
    guard let match = regex.firstMatch(in: text, range: range) else { return nil }

    let hour   = Int(nsText.substring(with: match.range(at: 1))) ?? 0
    let minute = match.range(at: 3).location != NSNotFound
                 ? (Int(nsText.substring(with: match.range(at: 3))) ?? 0) : 0
    var finalHour = hour
    if match.range(at: 4).location != NSNotFound {
        let ampm = nsText.substring(with: match.range(at: 4)).lowercased()
        if ampm == "pm" && hour != 12 { finalHour += 12 }
        if ampm == "am" && hour == 12 { finalHour = 0 }
    } else if hour < 7 { finalHour += 12 } // assume PM for ambiguous small hours

    return Calendar.current.date(bySettingHour: finalHour, minute: minute, second: 0, of: .now)
}

private func extractDuration(from text: String) -> Int? {
    let pattern = #"(\d+)\s*(minutes?|mins?|hours?|hrs?)"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
    let range = NSRange(text.startIndex..., in: text)
    guard let match = regex.firstMatch(in: text, range: range) else { return nil }
    let nsText = text as NSString
    let value  = Int(nsText.substring(with: match.range(at: 1))) ?? 0
    let unit   = nsText.substring(with: match.range(at: 2)).lowercased()
    return unit.hasPrefix("h") ? value * 60 : value
}

private func extractPriority(from text: String) -> Priority {
    if text.contains("urgent") || text.contains("important") || text.contains("asap") { return .high }
    if text.contains("low")    || text.contains("whenever")                            { return .low }
    return .normal
}

private func extractCategory(from text: String) -> TaskCategory {
    if text.contains("run") || text.contains("walk") || text.contains("gym") || text.contains("health") || text.contains("workout") { return .health }
    if text.contains("study") || text.contains("read") || text.contains("learn") || text.contains("review") { return .study }
    if text.contains("meeting") || text.contains("standup") || text.contains("call") || text.contains("work") || text.contains("email") { return .work }
    if text.contains("focus") || text.contains("deep work") || text.contains("code") || text.contains("build") { return .focus }
    return .personal
}

private func cleanTitle(_ text: String) -> String {
    // Remove time phrases but keep the core action
    var result = text
    let patterns = [
        #"\bat\s+\d{1,2}(:\d{2})?\s*(am|pm)?"#,
        #"\bfor\s+\d+\s*(minutes?|mins?|hours?|hrs?)"#,
        #"\btomorrow\b"#,
    ]
    for p in patterns {
        if let regex = try? NSRegularExpression(pattern: p, options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }
    }
    // Capitalise first letter
    result = result.trimmingCharacters(in: .whitespaces)
    return result.prefix(1).uppercased() + result.dropFirst()
}


