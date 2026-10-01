import AVFoundation
import SwiftUI

/// Procedural Audio Synthesizer and SFX Engine (No external sound files required).
@MainActor
final class AudioService {
    static let shared = AudioService()
    
    private var engine: AVAudioEngine?
    private var isMuted: Bool {
        !DinoGameManager.shared.soundEnabled
    }
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Procedural Tone Generation (8-Bit Retro Chimes)
    
    /// Play a retro jump sound (frequency sweep up).
    func playJumpSound() {
        guard !isMuted else { return }
        playTone(startFreq: 280, endFreq: 620, duration: 0.15, type: .square)
    }
    
    /// Play a high-pitched coin pickup chime.
    func playCoinSound() {
        guard !isMuted else { return }
        playTone(startFreq: 987, endFreq: 1318, duration: 0.12, type: .sine)
    }
    
    /// Play an energy shield break sound.
    func playShieldBreakSound() {
        guard !isMuted else { return }
        playTone(startFreq: 800, endFreq: 200, duration: 0.25, type: .sawtooth)
    }
    
    /// Play a game over crash rumble.
    func playGameOverSound() {
        guard !isMuted else { return }
        playTone(startFreq: 220, endFreq: 60, duration: 0.45, type: .noise)
    }
    
    /// Play button click sound.
    func playTapSound() {
        guard !isMuted else { return }
        playTone(startFreq: 440, endFreq: 440, duration: 0.04, type: .sine)
    }
    
    // MARK: - Core Audio Tone Generator
    private enum WaveType { case sine, square, sawtooth, noise }
    
    private func playTone(startFreq: Float, endFreq: Float, duration: Double, type: WaveType) {
        DispatchQueue.global(qos: .userInteractive).async {
            let sampleRate: Double = 44100.0
            let frameCount = Int(sampleRate * duration)
            
            guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
                return
            }
            
            buffer.frameLength = AVAudioFrameCount(frameCount)
            guard let channelData = buffer.floatChannelData?[0] else { return }
            
            var phase: Float = 0.0
            for i in 0..<frameCount {
                let progress = Float(i) / Float(frameCount)
                let currentFreq = startFreq + (endFreq - startFreq) * progress
                let phaseInc = (2.0 * Float.pi * currentFreq) / Float(sampleRate)
                
                var sample: Float = 0.0
                switch type {
                case .sine:
                    sample = sin(phase)
                case .square:
                    sample = sin(phase) >= 0 ? 0.4 : -0.4
                case .sawtooth:
                    sample = (phase / Float.pi) - 1.0
                case .noise:
                    sample = Float.random(in: -0.5...0.5)
                }
                
                // Linear decay envelope
                let envelope = 1.0 - progress
                channelData[i] = sample * envelope * 0.35
                
                phase += phaseInc
                if phase >= 2.0 * Float.pi { phase -= 2.0 * Float.pi }
            }
            
            let player = AVAudioPlayerNode()
            let audioEngine = AVAudioEngine()
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: format)
            
            do {
                try audioEngine.start()
                player.play()
                player.scheduleBuffer(buffer, at: nil, options: []) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        player.stop()
                        audioEngine.stop()
                    }
                }
            } catch {
                print("Failed to play audio buffer: \(error)")
            }
        }
    }
}
