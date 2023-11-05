//
//  AudioSettingsView.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

protocol AudioSettingsViewDelegate: AnyObject {
  func didTapPlayButtonAction()
  func didTapMicButtonAction()
  func didTapRecordButtonAction()
  func didTapLayersButtonAction()
}

final class AudioSettingsView: UIView {
  private let playButton: SettingButton = .create { button in
    button.setIconImage(image: UIImage(systemName: "arrowtriangle.right.fill"), size: .init(width: 18, height: 18))
  }
  private let micButton: SettingButton = .create { button in
    button.setIconImage(image: UIImage(systemName: "mic.fill"), size: .init(width: 18, height: 18))
  }
  private let recordButton: SettingButton = .create { button in
    button.setIconImage(image: UIImage(systemName: "circle.fill"), size: .init(width: 12, height: 12))
  }
  private let buttonsStackView: UIStackView = .create { stackView in
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 5
  }
  private let layersButton = LayersButton()
  
  weak var delegate: AudioSettingsViewDelegate?
  
  init() {
    super.init(frame: .zero)
    setupViews()
    addActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setActiveStateLayerButton(isActive: Bool) {
    layersButton.setupState(isActive: isActive)
  }
  
  private func setupViews() {
    buttonsStackView.addArrangedSubview(micButton)
    buttonsStackView.addArrangedSubview(recordButton)
    buttonsStackView.addArrangedSubview(playButton)
    
    addSubview(buttonsStackView)
    
    buttonsStackView.snp.makeConstraints { make in
      make.trailing.top.bottom.equalToSuperview()
    }
    
    addSubview(layersButton)
    layersButton.snp.makeConstraints { make in
      make.leading.centerY.equalToSuperview()
    }
  }
  
  private func addActions() {
    playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    micButton.addTarget(self, action: #selector(micButtonAction), for: .touchUpInside)
    recordButton.addTarget(self, action: #selector(recordButtonAction), for: .touchUpInside)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(layersButtonAction))
    layersButton.addGestureRecognizer(gesture)
  }
  
  @objc private func playButtonAction() {
    delegate?.didTapPlayButtonAction()
  }
  
  @objc private func micButtonAction() {
    delegate?.didTapMicButtonAction()
  }
  
  @objc private func recordButtonAction() {
    delegate?.didTapRecordButtonAction()
  }
  
  @objc private func layersButtonAction() {
    delegate?.didTapLayersButtonAction()
  }
}
