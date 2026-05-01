import SwiftUI

struct InputView: View {

    @ObservedObject var vm: TaskViewModel
    @Environment(\.dismiss) var dismiss

    @StateObject var speech = SpeechManager()
    @State private var isAnimating = false

    // Derived from SpeechManager so UI always stays in sync
    private var isRecording: Bool { speech.isRecording }

    var body: some View {
        ZStack {
            Color(hex: "F2F2F7").ignoresSafeArea() // bgGray
            
            VStack(spacing: 32) {
                // Header
                Text("Smart Add")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1C1C1E"))
                    .padding(.top, 32)

                // Input Area
                VStack(spacing: 16) {
                    TextField("Speak or type your tasks...", text: $speech.recognizedText, axis: .vertical)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "1C1C1E"))
                        .lineLimit(4...8)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)

                    // Error text
                    if let error = speech.errorMessage {
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "FF3B30"))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Mic Button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color(hex: "FF3B30").opacity(0.15) : Color.clear)
                            .frame(width: isRecording ? 100 : 80, height: isRecording ? 100 : 80)
                            .scaleEffect(isRecording && isAnimating ? 1.2 : 1.0)
                            .opacity(isRecording && isAnimating ? 0 : 1)
                            .animation(isRecording ? Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false) : .default, value: isAnimating)

                        Circle()
                            .fill(isRecording ? Color(hex: "FF3B30") : Color(hex: "5E5CE6")) // indigo
                            .frame(width: 80, height: 80)
                            .shadow(color: (isRecording ? Color(hex: "FF3B30") : Color(hex: "5E5CE6")).opacity(0.35), radius: 12, y: 6)

                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
                .onChange(of: isRecording) { recording in
                    if recording {
                        isAnimating = true
                    } else {
                        isAnimating = false
                    }
                }

                Spacer()

                // Add Button
                Button(action: {
                    vm.addTasks(from: speech.recognizedText)
                    dismiss()
                }) {
                    Text("Add Tasks")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            speech.recognizedText.trimmingCharacters(in: .whitespaces).isEmpty ?
                            Color(hex: "8E8E93").opacity(0.3) : Color(hex: "5E5CE6")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: speech.recognizedText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.clear : Color(hex: "5E5CE6").opacity(0.3), radius: 8, y: 4)
                }
                .disabled(speech.recognizedText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        // Stop recording if the sheet is dismissed mid-session
        .onDisappear {
            if isRecording {
                speech.stopRecording()
            }
        }
        // Surface permission / recognizer errors via alert
        .alert("Error", isPresented: .constant(speech.errorMessage != nil)) {
            Button("OK") { speech.errorMessage = nil }
        } message: {
            Text(speech.errorMessage ?? "")
        }
        .onAppear {
            speech.requestPermissions()
        }
    }

    // MARK: - Helpers

    private func toggleRecording() {
        if isRecording {
            speech.stopRecording()
        } else {
            speech.startRecording()
        }
    }
}


