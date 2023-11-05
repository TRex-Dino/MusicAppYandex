//
//  ViewController.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 31.10.2023.
//

import UIKit
import SnapKit
import AVFoundation

struct TrackModel {
  let uuid: UUID
  let audioFile: AVAudioFile?
  let name: String
  var isVolumeOn: Bool
  var isPlaying: Bool
  var isActive: Bool
}

final class ViewController: UIViewController {

  private var tracks = [TrackModel]()

  private let gradientView = GradientView()
  private let audioSettingsView = AudioSettingsView()
  private let instrumentsPickerView = InstrumentsPickerView()
  private let player = AudioPlayer()

  private let layerListViewController = LayerListViewController()

  private var layerButtonIsActive = false {
    didSet {
      audioSettingsView.setActiveStateLayerButton(isActive: layerButtonIsActive)
      gradientView.isHidingSliders(isHiding: layerButtonIsActive)
    }
  }

  private var isAudioPlaying = false
  private var currentIndex = 0


  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black
    setupSettingsView()
    setupInstrumentsPickerView()
    setupGradientView()
  }

  func setupGradientView() {
    view.addSubview(gradientView)

    gradientView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(15)
      make.top.equalTo(instrumentsPickerView.snp.bottom)
      make.bottom.equalTo(audioSettingsView.snp.top).offset(-15)
    }
    gradientView.setDelegate(delegate: self, soundDelegate: self)
  }

  private func setupSettingsView() {
    view.addSubview(audioSettingsView)
    audioSettingsView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(15)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      make.height.equalTo(34)
    }
    audioSettingsView.delegate = self
  }

  private func setupInstrumentsPickerView() {
    view.addSubview(instrumentsPickerView)
    instrumentsPickerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(15)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.height.equalTo(120)
    }
    instrumentsPickerView.setDelegate(self)
  }

  private let audioRecorder = AudioRecorder(numberOfSamples: 1)
}

extension ViewController: InstrumentViewDelegate {
  func didTapInstrument(_ instrument: InstrumentView.Instrument) {
    isAudioPlaying = true
    let url = Bundle.main.url(forResource: instrument.audioName, withExtension: "wav")!
    let file = try? AVAudioFile(forReading: url)
    let model = TrackModel(
      uuid: UUID(),
      audioFile: file,
      name: instrument.name,
      isVolumeOn: true,
      isPlaying: true,
      isActive: true
    )
    if tracks.count > currentIndex, !tracks.isEmpty {
      tracks[currentIndex].isActive = false
    }
    currentIndex = tracks.count
    tracks.append(model)
    updateListViewHeight()
    player.play(by: model)
  }
}

extension ViewController: AudioSettingsViewDelegate {
  func didTapPlayButtonAction() {
    if isAudioPlaying {
      player.pauseAll()
      isAudioPlaying = false
    } else {
      player.playAll(models: tracks)
      isAudioPlaying = true
    }
  }

  func didTapMicButtonAction() {

  }

  func didTapRecordButtonAction() {
    player.saveAudio { [weak self] result in
      switch result {
      case .success(let file):
        self?.presentActivity(file: file)
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }

  private func presentActivity(file: AVAudioFile) {
    let activityViewController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
    player.pauseAll()
  }

  func didTapLayersButtonAction() {
    guard !tracks.isEmpty else {
      return
    }
    layerButtonIsActive.toggle()

    if layerButtonIsActive {
      addSamplesListController()
    } else if layerListViewController.parent != nil {
      dismissSamplesList()
    }
  }

}

extension ViewController: TrackCollectionViewCellDelegate {
  func trackDidTapped(at index: Int) {
    guard !tracks.isEmpty else { return }
    let isActive = tracks[index].isActive
    if isActive {
      return
    }

    tracks[index].isActive = true
    tracks[currentIndex].isActive = false
    currentIndex = index
    layerListViewController.setTracks(tracks)
  }

  func trackDidTapRemoveButton(at index: Int) {
    player.removeTrack(at: tracks[index].uuid)
    tracks.remove(at: index)
    if index == currentIndex, !tracks.isEmpty {
      currentIndex = tracks.count - 1
      tracks[currentIndex].isActive = true
    }
    if tracks.isEmpty, layerListViewController.parent != nil {
      dismissSamplesList()
      layerButtonIsActive = false
    } else {
      updateListViewHeight()
    }
  }

  func trackDidTapPlayButton(at index: Int) {
    let track = tracks[index]
    var isPlaying = track.isPlaying
    isPlaying.toggle()
    if isPlaying {
      player.play(by: track)
    } else {
      player.pause(track.uuid)
    }
    tracks[index].isPlaying = isPlaying
    // æ reload cell to change icon
  }

  func trackDidTapSoundButton(at index: Int) {
    let track = tracks[index]
    var isVolumeOn = track.isVolumeOn
    isVolumeOn.toggle()
    if isVolumeOn {
      player.updateSound(at: track.uuid, value: 1)
    } else {
      player.updateSound(at: track.uuid, value: 0)
    }
    tracks[index].isVolumeOn = isVolumeOn
    // æ reload cell to change icon
  }

}


extension ViewController {
  private func dismissSamplesList() {
    layerListViewController.willMove(toParent: nil)
    layerListViewController.view.removeFromSuperview()
    layerListViewController.removeFromParent()
  }

  private func addSamplesListController() {
    guard !tracks.isEmpty else { return }
    layerListViewController.delegate = self

    addChild(layerListViewController)
    view.addSubview(layerListViewController.view)
    layerListViewController.didMove(toParent: self)

    updateListViewHeight()
  }

  private func updateListViewHeight() {
    guard layerButtonIsActive else { return }
    let height = tracks.count * (7+39) - 7

    layerListViewController.view.snp.remakeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(15)
      make.bottom.equalTo(gradientView.snp.bottom)
      make.height.equalTo(height)
    }

    layerListViewController.setTracks(tracks)
  }
}


extension ViewController: SpeedValueSliderViewDelegate {
  func speedValueChanged(_ value: Float) {
    guard !tracks.isEmpty else { return }
    player.updateSpeedRate(at: tracks[currentIndex].uuid, value: value)
  }
}

extension ViewController: SoundValueSliderViewDelegate {
  func soundValueChanged(_ value: Float) {
    guard !tracks.isEmpty else { return }
    player.updateSound(at: tracks[currentIndex].uuid, value: value)
  }
}
