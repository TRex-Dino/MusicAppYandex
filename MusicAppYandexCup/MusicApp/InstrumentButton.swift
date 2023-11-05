//
//  InstrumentButton.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

protocol InstrumentViewDelegate: AnyObject {
  func didTapInstrument(_ instrument: InstrumentView.Instrument)
}

final class InstrumentView: UIView {
  private let imageView: UIImageView = .create { imageView in
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .black
  }
  private let instrumentLabel: UILabel = .create { label in
    label.textAlignment = .center
    label.textColor = .white
  }
  private let instrumentButton: UIView = .create { button in
    button.layer.cornerRadius = 30.5
    button.backgroundColor = .white
  }
  
  weak var delegate: InstrumentViewDelegate?
  
  var isEnabled: Bool = true {
    didSet {
      UIView.animate(withDuration: 0.3) {
        self.alpha = self.isEnabled ? 1 : 0.3
      }
    }
  }
  
  private let instrument: Instrument
  
  init(instrument: Instrument) {
    self.instrument = instrument
    super.init(frame: .zero)
    setupViews()
    setupImage()
    addAction()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
  }
  
  private func setupImage() {
    let image = UIImage(named: instrument.rawValue)
    imageView.image = image
    
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(instrument.imageTopOffset)
      make.size.equalTo(instrument.imageSize)
    }
    instrumentLabel.text = instrument.name
  }
  
  private func setupViews() {
    addSubview(instrumentButton)
    addSubview(instrumentLabel)
    instrumentButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(15)
      make.size.equalTo(61)
    }
    
    instrumentLabel.snp.makeConstraints { make in
      make.centerX.equalTo(instrumentButton.snp.centerX)
      make.top.equalTo(instrumentButton.snp.bottom).offset(9)
      make.bottom.equalToSuperview().offset(-15)
    }
    instrumentButton.addSubview(imageView)
  }
  
  private func addAction() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
    instrumentButton.addGestureRecognizer(tapGesture)
  }
  
  @objc private func buttonTapped() {
    delegate?.didTapInstrument(instrument)
  }
}
extension InstrumentView {
  enum Instrument: String {
    case guitar = "guitarInstrument"
    case bass = "bassInstrument"
    case wind = "windInstrument"
    
    var imageSize: CGSize {
      switch self {
      case .guitar:
        return .init(width: 26, height: 49)
      case .bass:
        return .init(width: 34, height: 26)
      case .wind:
        return .init(width: 44, height: 22)
      }
    }
    
    var imageTopOffset: CGFloat {
      switch self {
      case .guitar:
        return 16
      case .bass:
        return 17
      case .wind:
        return 20
      }
    }
    
    var audioName: String {
      switch self {
      case .guitar:
        return "guitar"
      case .bass:
        return "bass"
      case .wind:
        return "wind"
      }
    }
    
    var name: String {
      switch self {
      case .guitar:
        return "гитара"
      case .bass:
        return "ударные"
      case .wind:
        return "духовые"
      }
    }
  }
}
