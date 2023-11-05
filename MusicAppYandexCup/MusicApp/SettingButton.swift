//
//  SettingButton.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

final class SettingButton: UIButton {
  private let contentView = UIView()
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setIconImage(image: UIImage?, size: CGSize) {
    let iconImage = UIImageView()
    iconImage.image = image
    
    contentView.addSubview(iconImage)
    iconImage.image = image
    iconImage.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(size)
    }
  }
  
  private func setup() {
    tintColor = .black
    backgroundColor = .white
    layer.cornerRadius = 4
    contentView.isUserInteractionEnabled = false
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(8)
      make.size.equalTo(CGSize(width: 18, height: 18))
    }
  }
}
