# Planora 

Planora is a voice-first smart planner that transforms natural speech into structured, time-based tasks. Built using SwiftUI and Apple’s Speech framework, it enables users to plan their day effortlessly—just by speaking.

Overview

Planning tasks shouldn’t feel like a chore. Most productivity apps require manual input, which adds friction and slows users down.

Planora simplifies this process by allowing users to describe their plans naturally. The app intelligently interprets spoken input and converts it into organized, time-based tasks.

For example:

* “Meditate at 6 for 30 minutes”
* “Study at 8”
* “Workout and dinner at 9”

Planora processes these inputs in real time and structures them into a clear, manageable schedule.

---

 Key Features

Voice-Driven Task Creation

* Real-time speech-to-text conversion
* Seamless microphone interaction
* Natural language input instead of manual typing

Intelligent Parsing Engine

* Extracts:

  * Task title
  * Start time
  * Duration
* Supports multi-task inputs
* Handles flexible formats like:

  * “6”, “6:30”, “30 minutes”
Clean & Minimal Interface

* Distraction-free design
* Task cards with clear time ranges
* Inspired by Apple’s Human Interface Guidelines

### ⚡ Fast & Responsive

* Instant task creation from voice input
* Lightweight and smooth performance

---

## 📱 User Flow

1. Tap the microphone button
2. Speak your task naturally
3. View live transcription
4. Confirm and add tasks
5. Tasks appear instantly in your schedule

---

## 🧪 Example Inputs

* “Study at 6”
* “Meditate at 6 for 30 minutes”
* “Workout at 7 and dinner at 9”
* “Call mom at 8 pm”

---

## 🛠️ Tech Stack

* **SwiftUI** – UI development
* **Combine** – State management
* **Speech Framework** – Speech recognition
* **AVFoundation** – Audio handling

---

## 🧱 Architecture

**Model**

* `Task.swift`

**ViewModel**

* `TaskViewModel.swift`
* `SpeechManager.swift`

**Views**

* `ContentView.swift`
* `InputView.swift`

---

## 🎯 Design Philosophy

Planora is built around a simple idea:

> Planning should feel as natural as speaking.

The app focuses on:

* Reducing friction in task creation
* Leveraging natural human interaction
* Maintaining clarity through minimal design

---

## 🔮 Future Scope

* 📅 Timeline-based scheduling view
* ⚠️ Conflict detection between tasks
* 🤖 Smart suggestions for free time slots
* 🔊 Voice feedback (text-to-speech)
* ☁️ Cloud sync

---

## 📸 Demo

> *(Add screenshots or a short demo video here for best impact)*

---

## 👨💻 Author

Developed as part of an iOS development initiative focused on building intuitive, human-centered productivity tools.

---

## ⭐ Acknowledgment

Planora explores how voice interfaces can redefine productivity by reducing interaction overhead and making planning more intuitive.

---

⭐ If you found this project interesting, consider starring the repository!
