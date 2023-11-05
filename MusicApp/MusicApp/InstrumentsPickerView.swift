//
//  InstrumentsPickerView.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit


final class InstrumentsPickerView: UIView {
  private let guitarButton = InstrumentView(instrument: .guitar)
  private let bassButton = InstrumentView(instrument: .bass)
  private let windButton = InstrumentView(instrument: .wind)

  init() {
    super.init(frame: .zero)
    setupViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setDelegate(_ delegate: InstrumentViewDelegate?) {
    guitarButton.delegate = delegate
    bassButton.delegate = delegate
    windButton.delegate = delegate
  }

  private func setupViews() {
    addSubview(guitarButton)
    guitarButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    addSubview(bassButton)
    bassButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    addSubview(windButton)
    windButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}



