import Foundation
import Speech
import AVFoundation
import Combine

class SpeechManager: ObservableObject {

    @Published var recognizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String? = nil

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startRecording() {
        recognizedText = ""
        errorMessage = nil
        
        guard let recognizer = recognizer else {
            errorMessage = "Failed to initialize recognizer. Make sure Dictation is enabled."
            return
        }
        
        guard recognizer.isAvailable else {
            errorMessage = "Speech recognizer is not available right now. Please try on a real device or enable Dictation in Settings."
            return
        }
        
        // Stop previous session safely
        stopRecording()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let audioSession = AVAudioSession.sharedInstance()
        
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Audio session error: \(error.localizedDescription)"
                }
                return
            }
            
            let node = self.audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        // Bulletproof fallback for Simulator 0Hz sample rate issue
        let format = recordingFormat.sampleRate == 0 ? AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)! : recordingFormat
        
            node.removeTap(onBus: 0)
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            self.recognitionRequest = request
            request.shouldReportPartialResults = true
            
            self.recognitionTask = self.recognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain != "kAFAssistantErrorDomain" {
                        self.errorMessage = error.localizedDescription
                    }
                    self.stopRecording()
                }
            }
        }
        
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            
            self.audioEngine.prepare()
            
            do {
                try self.audioEngine.start()
                DispatchQueue.main.async {
                    self.isRecording = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Audio engine failed: \(error.localizedDescription)"
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.errorMessage = "Speech permission not granted"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.errorMessage = "Microphone permission not granted"
                }
            }
        }
    }
}
