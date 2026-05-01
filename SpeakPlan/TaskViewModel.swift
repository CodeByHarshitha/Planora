import Foundation
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {

    @Published var tasks: [Task] = []
    @Published var selectedDate: Date = .now

    private let saveKey = "speakplan.tasks.v2"

    init() { load() }

    // MARK: - Public API

    func addTasks(from input: String) {
        let new = parseInput(input)
        tasks.append(contentsOf: new)
        save()
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        save()
    }

    func toggleCompletion(for task: Task) {
        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[i].isCompleted.toggle()
        save()
    }

    // MARK: - Filtered views (for timeline sections)

    var morningTasks: [Task] {
        tasksForSelectedDate.filter {
            guard let s = $0.startTime else { return true }
            return Calendar.current.component(.hour, from: s) < 12
        }
    }

    var afternoonTasks: [Task] {
        tasksForSelectedDate.filter {
            guard let s = $0.startTime else { return false }
            return Calendar.current.component(.hour, from: s) >= 12
        }
    }

    var sortedTasksForSelectedDate: [Task] {
        tasksForSelectedDate.sorted {
            let t1 = $0.startTime ?? Date.distantFuture
            let t2 = $1.startTime ?? Date.distantFuture
            return t1 < t2
        }
    }

    var tasksForSelectedDate: [Task] {
        tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // MARK: - Persistence

    private func save() {
        guard let encoded = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(encoded, forKey: saveKey)
    }

    private func load() {
        guard
            let data    = UserDefaults.standard.data(forKey: saveKey),
            let decoded = try? JSONDecoder().decode([Task].self, from: data)
        else { return }
        tasks = decoded
    }
}
