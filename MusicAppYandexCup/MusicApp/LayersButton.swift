//
//  LayersButton.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

final class LayersButton: UIView {
  private let iconImage = UIImageView()
  private let label: UILabel = .create { label in
    label.font = .systemFont(ofSize: 12)
    label.textColor = .black
  }
  
  init() {
    super.init(frame: .zero)
    setupViews()
    setupState(isActive: false)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupState(isActive: Bool) {
    iconImage.image = isActive ? UIImage(named: "chevronDown") : UIImage(named: "chevronUp")
    backgroundColor = isActive ? .green : .white
  }
  
  private func setupViews() {
    addSubview(iconImage)
    addSubview(label)
    label.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(10)
      make.top.bottom.equalToSuperview().inset(10)
    }
    iconImage.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.size.equalTo(CGSize(width: 12, height: 6))
      make.leading.equalTo(label.snp.trailing).offset(16)
      make.trailing.equalToSuperview().offset(-10)
    }
    
    layer.cornerRadius = 4
    label.text = "Слои"
    iconImage.contentMode = .scaleAspectFit
    iconImage.tintColor = .black
  }
}
