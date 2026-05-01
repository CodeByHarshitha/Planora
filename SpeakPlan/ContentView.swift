import SwiftUI

// MARK: - Design tokens (matching the HTML prototype)

private let indigo    = Color(hex: "5E5CE6")
private let bgGray    = Color(hex: "F2F2F7")
private let labelGray = Color(hex: "8E8E93")
private let subGray   = Color(hex: "636366")

// MARK: - ContentView

struct ContentView: View {
    @StateObject var vm = TaskViewModel()
    @State private var showInput = false

    // 7-day strip starting Monday of this week
    private var weekDays: [Date] {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today)   // 1=Sun … 7=Sat
        let offset  = (weekday == 1 ? -6 : 2 - weekday)     // shift to Monday
        return (0..<7).compactMap {
            cal.date(byAdding: .day, value: offset + $0, to: today)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            bgGray.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                dateStrip
                taskList
            }

            // FAB
            Button { showInput = true } label: {
                ZStack {
                    Circle()
                        .fill(indigo)
                        .frame(width: 56, height: 56)
                        .shadow(color: indigo.opacity(0.35), radius: 10, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 32)
            .accessibilityLabel("Add task")
        }
        .sheet(isPresented: $showInput) {
            InputView(vm: vm)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SpeakPlan")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1C1C1E"))
                    .kerning(-0.5)
                Text(vm.selectedDate.formatted(date: .long, time: .omitted))
                    .font(.system(size: 14))
                    .foregroundColor(labelGray)
            }
            Spacer()
            // Avatar
            Circle()
                .fill(indigo)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )
                .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(bgGray)
    }

    // MARK: - Date Strip

    private var dateStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(weekDays, id: \.self) { day in
                    DateChip(date: day, isSelected: Calendar.current.isDate(day, inSameDayAs: vm.selectedDate)) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            vm.selectedDate = day
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
        .background(bgGray)
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                if vm.tasksForSelectedDate.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(vm.sortedTasksForSelectedDate.enumerated()), id: \.element.id) { i, task in
                        TaskRow(task: task, isFirst: i == 0, animationDelay: Double(i) * 0.06, vm: vm)
                    }
                }

                // Empty slot
                emptySlot

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
        }
    }



    private var emptySlot: some View {
        let hasTasks = !vm.tasksForSelectedDate.isEmpty
        return HStack(alignment: .top, spacing: 0) {
            Text("Free")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "8E8E93"))
                .frame(width: 50, alignment: .trailing)
                .padding(.top, 24)
            
            // Timeline Graphics
            ZStack(alignment: .top) {
                if hasTasks {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: "D1D1D6"))
                            .frame(width: 2, height: 26)
                        Spacer()
                    }
                }
                
                Circle()
                    .stroke(Color(hex: "D1D1D6"), lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .background(Circle().fill(bgGray))
                    .padding(.top, 24)
            }
            .frame(width: 30)
            .padding(.horizontal, 4)

            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "D1D1D6"), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(
                    Text("Free slot · tap + to add")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                )
                .onTapGesture { showInput = true }
                .padding(.top, 10)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundColor(labelGray.opacity(0.5))
                .padding(.top, 60)
            Text("No Tasks Yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "1C1C1E"))
            Text("Tap + to speak or type your tasks.")
                .font(.system(size: 15))
                .foregroundColor(labelGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - DateChip

struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    private let cal = Calendar.current
    private var dayName: String {
        date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
    }
    private var dayNum: String {
        date.formatted(.dateTime.day())
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(dayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.75) : Color(hex: "8E8E93"))
                Text(dayNum)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(hex: "1C1C1E"))
            }
            .frame(minWidth: 48)
            .padding(.vertical, 9)
            .padding(.horizontal, 6)
            .background(isSelected ? Color(hex: "5E5CE6") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TaskRow  (time column + colored card)

struct TaskRow: View {
    let task: Task
    let isFirst: Bool
    let animationDelay: Double
    @ObservedObject var vm: TaskViewModel

    @State private var appeared = false
    @State private var expanded = false
    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Time column
            VStack(alignment: .trailing, spacing: 4) {
                if let s = task.startTime {
                    Text(s.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "1C1C1E"))
                } else {
                    Text("Any")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                
                if let e = task.endTime {
                    Text(e.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
            }
            .frame(width: 50, alignment: .trailing)
            .padding(.top, 24)

            // Timeline Graphics
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color(hex: "D1D1D6"))
                    .frame(width: 2)
                    .padding(.top, isFirst ? 26 : 0)
                
                Circle()
                    .fill(task.isCompleted ? Color(hex: "30D158") : task.category.stripeColor)
                    .frame(width: 14, height: 14)
                    .background(Circle().fill(bgGray).frame(width: 22, height: 22))
                    .padding(.top, 24)
            }
            .frame(width: 30)
            .padding(.horizontal, 4)

            // Card (swipe-to-delete)
            ZStack(alignment: .trailing) {
                // Red delete bg
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "FF3B30"))
                    .overlay(
                        Text("Delete")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.trailing, 20),
                        alignment: .trailing
                    )
                    .opacity(showDelete ? 1 : 0)

                taskCard
                    .offset(x: offset)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { v in
                                if v.translation.width < 0 {
                                    offset = max(v.translation.width, -100)
                                    showDelete = offset < -40
                                }
                            }
                            .onEnded { v in
                                if v.translation.width < -80 {
                                    withAnimation(.easeIn(duration: 0.22)) {
                                        offset = -400
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        if let idx = vm.tasks.firstIndex(where: { $0.id == task.id }) {
                                            vm.delete(at: IndexSet(integer: idx))
                                        }
                                    }
                                } else {
                                    withAnimation(.spring()) { offset = 0; showDelete = false }
                                }
                            }
                    )
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 22)
                .delay(animationDelay)) {
                appeared = true
            }
        }
    }

    private var taskCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "1C1C1E"))
                    .strikethrough(task.isCompleted, color: Color(hex: "8E8E93"))
                    .lineLimit(2)
                Spacer()
                // Priority dot
                Circle()
                    .fill(task.priority.dotColor)
                    .frame(width: 9, height: 9)
                    .padding(.top, 4)
            }

            if let s = task.startTime, let e = task.endTime {
                Text("\(s.formatted(.dateTime.hour().minute())) – \(e.formatted(.dateTime.hour().minute()))")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "636366"))
                    .padding(.top, 5)
            }

            HStack {
                // Category tag
                Text(task.category.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(task.category.tagForeground)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(task.category.tagBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Spacer()

                // Completion checkmark
                Button {
                    vm.toggleCompletion(for: task)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? Color.clear : Color(hex: "C7C7CC"), lineWidth: 1.5)
                            .background(
                                Circle().fill(task.isCompleted ? Color(hex: "30D158") : .clear)
                            )
                            .frame(width: 24, height: 24)
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)

            // Expanded detail
            if expanded {
                Divider()
                    .padding(.top, 10)
                HStack(spacing: 16) {
                    Label("Reminder set", systemImage: "clock")
                    Label("Tap to edit", systemImage: "pencil")
                    Label("Swipe to delete", systemImage: "trash")
                }
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "636366"))
                .padding(.top, 8)
            }
        }
        .padding(14)
        .background(task.category.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            // Left stripe
            HStack {
                Rectangle()
                    .fill(task.category.stripeColor)
                    .frame(width: 4)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: 16
                        )
                    )
                Spacer()
            }
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.22)) { expanded.toggle() }
        }
    }
}
