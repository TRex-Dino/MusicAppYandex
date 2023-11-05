//
//  TrackCollectionViewCell.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

protocol TrackCollectionViewCellDelegate: AnyObject {
  func trackDidTapRemoveButton(at index: Int)
  func trackDidTapPlayButton(at index: Int)
  func trackDidTapSoundButton(at index: Int)
  func trackDidTapped(at index: Int)
}

final class TrackCollectionViewCell: UICollectionViewCell {
  static let identifier = "trackCell"
  weak var delegate: TrackCollectionViewCellDelegate?
  private var index: Int = 0

  private let containerView: UIView = .create { view in
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 4
  }

  private let closeView: UIView = .create { view in
    view.backgroundColor = .lightGray.withAlphaComponent(0.5)
    view.clipsToBounds = true
    view.layer.cornerRadius = 4
  }

  private let closeIconView: UIImageView = .create { imageView in
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .black
    imageView.image = UIImage(named: "xmark")
  }

  private let playIconView: UIImageView = .create { imageView in
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .black
    imageView.image = UIImage(named: "play")
    imageView.isUserInteractionEnabled = true
  }

  private let soundIconView: UIImageView = .create { imageView in
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .black
    imageView.image = UIImage(named: "sound")
    imageView.isUserInteractionEnabled = true
  }

  private let trackLabel: UILabel = .create { label in
    label.text = "No name"
    label.textColor = .black
    label.font = .systemFont(ofSize: 12)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    addGestures()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setTrackName(_ name: String, index: Int) {
    trackLabel.text = "Track \(index) \(name)"
    self.index = index
  }

  func contentColor(isActive: Bool) {
    containerView.backgroundColor = isActive ? .green : .white
  }

  private func setupViews() {
    contentView.addSubview(containerView)

    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    containerView.addSubview(closeView)
    closeView.snp.makeConstraints { make in
      make.width.equalTo(39)
      make.bottom.trailing.top.equalToSuperview()
    }
    closeView.addSubview(closeIconView)
    closeIconView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.size.equalTo(14)
    }

    containerView.addSubview(playIconView)
    containerView.addSubview(soundIconView)

    soundIconView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.size.equalTo(18)
      make.trailing.equalTo(closeView.snp.leading).offset(-12)
    }

    playIconView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.size.equalTo(18)
      make.trailing.equalTo(soundIconView.snp.leading).offset(-12)
    }

    containerView.addSubview(trackLabel)
    trackLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(10)
    }
  }

  private func addGestures() {
    let tapCloseGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
    closeView.addGestureRecognizer(tapCloseGesture)

    let tapSoundGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
    soundIconView.addGestureRecognizer(tapSoundGesture)

    let tapPlayGesture = UITapGestureRecognizer(target: self, action: #selector(soundButtonTapped))
    playIconView.addGestureRecognizer(tapPlayGesture)
  }

  @objc private func closeButtonTapped() {
    delegate?.trackDidTapRemoveButton(at: index)
  }

  @objc private func playButtonTapped() {
    delegate?.trackDidTapPlayButton(at: index)
  }

  @objc private func soundButtonTapped() {
    delegate?.trackDidTapSoundButton(at: index)
  }

}
