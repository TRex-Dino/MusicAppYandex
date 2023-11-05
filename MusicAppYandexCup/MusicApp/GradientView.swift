//
//  GradientView.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

final class GradientView: UIView {
  private let speedValueSlider = SpeedValueSliderView()
  private let soundValueSlider = SoundValueSliderView()
  
  private lazy var gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.type = .axial
    gradient.colors = [
      UIColor.black.cgColor,
      UIColor.systemBlue.cgColor
    ]
    gradient.locations = [0, 1.4]
    return gradient
  }()
  
  
  init() {
    super.init(frame: .zero)
    setupSpeed()
    setupSound()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    gradientLayer.frame = bounds
    layer.insertSublayer(gradientLayer, at: 0)
  }
  
  func setDelegate(delegate: SpeedValueSliderViewDelegate?, soundDelegate: SoundValueSliderViewDelegate?) {
    speedValueSlider.delegate = delegate
    soundValueSlider.delegate = soundDelegate
  }
  
  func isHidingSliders(isHiding: Bool) {
    speedValueSlider.isHidden = isHiding
    soundValueSlider.isHidden = isHiding
  }
  
  private func setupSpeed() {
    addSubview(speedValueSlider)
    
    
    speedValueSlider.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.leading.equalToSuperview().offset(35)
      make.bottom.equalToSuperview()
      make.height.equalTo(14)
    }
    
  }
  
  private func setupSound() {
    addSubview(soundValueSlider)
    soundValueSlider.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().offset(-26)
      make.width.equalTo(14)
    }
  }
}
