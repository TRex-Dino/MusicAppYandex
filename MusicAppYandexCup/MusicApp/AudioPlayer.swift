//
//  AudioPlayer.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import Foundation
import AVFoundation

final class AudioPlayer {
  private let audioEngine = AVAudioEngine()
  private var mixer = AVAudioMixerNode()
  
  private var nodes = [UUID: AVAudioPlayerNode]()
  private var pitches = [UUID: AVAudioUnitTimePitch]()
  private var avAudioNodeBuses = [UUID: AVAudioNodeBus]()
  private var toBusAVAudioNodeBus = AVAudioNodeBus.min
  
  private var speedRate: Float = 1
  private var soundValue: Float = 0
  
  var isPlaying: Bool {
    audioEngine.isRunning
  }
  
  init() {
    prepareAudioSession()
    configureAudioEngine()
  }
  
  private func getNode(at model: TrackModel) -> AVAudioPlayerNode {
    if let node = nodes[model.uuid] {
      return node
    }
    return prepareNode(at: model)
  }
  
  private func prepareNode(at model: TrackModel) -> AVAudioPlayerNode {
    let pitch = AVAudioUnitTimePitch()
    pitches[model.uuid] = pitch
    
    let node = AVAudioPlayerNode()
    
    nodes[model.uuid] = node
    audioEngine.attach(node)
    audioEngine.attach(pitch)
    
    audioEngine.connect(node, to: pitch, format: nil)
    let mixerNodeInputBus = getBus(by: model)
    
    audioEngine.connect(
      pitch,
      to: mixer,
      fromBus: .zero,
      toBus: mixerNodeInputBus,
      format: nil
    )
    audioEngine.prepare()
    return node
  }
  
  private func getBus(by model: TrackModel) -> AVAudioNodeBus {
    if let bus = avAudioNodeBuses[model.uuid] {
      return bus
    }
    let bus = toBusAVAudioNodeBus
    avAudioNodeBuses[model.uuid] = bus
    toBusAVAudioNodeBus += 1
    return bus
  }
  
  
  private func configureAudioEngine() {
    audioEngine.attach(mixer)
    audioEngine.connect(mixer, to: audioEngine.mainMixerNode, fromBus: .zero, toBus: .zero, format: nil)
    audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, fromBus: .zero, toBus: .zero, format: nil)
    audioEngine.prepare()
  }
  
  private func startAudioEngine() {
    do {
      try audioEngine.start()
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  private func prepareAudioSession() {
    let session = AVAudioSession.sharedInstance()
    
    do {
      try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
}

extension AudioPlayer {
  func play(by model: TrackModel) {
    if !isPlaying {
      configureAudioEngine()
      startAudioEngine()
    }
    let player = getNode(at: model)
    guard !player.isPlaying, let audioFile = model.audioFile else { return }
    audioFile.framePosition = 0
    let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                  frameCapacity: AVAudioFrameCount(audioFile.length))
    
    
    try! audioFile.read(into: buffer!)
    player.scheduleBuffer(buffer!, at: nil, options: .loops)
    player.play()
  }
  
  func updateSound(at uuid: UUID, value: Float) {
    guard isPlaying, let node = nodes[uuid] else { return }
    node.volume = value
  }
  
  func updateSpeedRate(at uuid: UUID, value: Float) {
    guard isPlaying, let pitch = pitches[uuid] else { return }
    pitch.rate = value
  }
  
  func pauseAll() {
    for node in nodes.keys {
      pause(node)
    }
  }
  
  func playAll(models: [TrackModel]) {
    for model in models {
      play(by: model)
    }
  }
  
  func pause(_ uuid: UUID) {
    guard let node = nodes[uuid] else { return }
    node.pause()
  }
  
  func removeTrack(at index: UUID) {
    guard let node = nodes[index] else { return }
    if node.isPlaying {
      node.stop()
    }
    audioEngine.disconnectNodeOutput(node, bus: 0)
    audioEngine.detach(node)
    nodes[index] = nil
  }
  
  func saveAudio(completion: @escaping (Result<AVAudioFile, Error>) -> Void) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      
      let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let audioFilename = documentPath.appendingPathComponent("\(UUID().uuidString).m4a")
      do {
        let audioFile = try AVAudioFile(
          forWriting: audioFilename,
          settings: audioEngine.mainMixerNode.outputFormat(forBus: .zero).settings
        )
        completion(.success(audioFile))
      } catch {
        completion(.failure(error))
      }
    }
  }
}


