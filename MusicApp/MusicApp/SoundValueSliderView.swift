//
//  SoundValueSliderView.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 04.11.2023.
//

import UIKit

protocol SoundValueSliderViewDelegate: AnyObject {
  func soundValueChanged(_ value: Float)
}

final class SoundValueSliderView: UIView {

  weak var delegate: SoundValueSliderViewDelegate?

  override class var layerClass: AnyClass {
    return CAShapeLayer.self
  }

  private let thumbView = SoundControlSliderThumb()

  private var bottomConstraint: NSLayoutConstraint?
  private var panGestureRecognizer: UIPanGestureRecognizer!
  private var thumbViewBottomValue: CGFloat {
    bounds.height - thumbView.bounds.height
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    addGestures()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    createShapeLayer()
  }

  private func createShapeLayer() {
    let bezier = UIBezierPath()
    let lineWidth: CGFloat = 1
    var y: CGFloat = bounds.maxY
    let offset: CGFloat = 11
    var i = 0
    while y >= 0 {
      bezier.move(to: CGPoint(x: 0, y: y))
      bezier.addLine(to: CGPoint(x: i % 5 == 0 ? 14 : 7, y: y))
      y -= (lineWidth + offset)
      i += 1
    }

    let shapeLayer = self.layer as! CAShapeLayer
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.masksToBounds = true

    shapeLayer.path = bezier.cgPath
  }

  private func setupView() {
    addSubview(thumbView)
    thumbView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.size.equalTo(CGSize(width: 14, height: 64))
    }
    bottomConstraint = thumbView.bottomAnchor.constraint(equalTo: bottomAnchor)
    bottomConstraint?.isActive = true
  }

  private func addGestures() {
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGestureRecognizer.minimumNumberOfTouches = 0
    thumbView.addGestureRecognizer(panGestureRecognizer)
  }

  @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    guard let bottomConstraintValue = bottomConstraint?.constant else {
      return
    }
    var translation = sender.translation(in: self)
    switch sender.state {
    case .changed:
      var draggedDistance: CGFloat = bottomConstraintValue + translation.y
      if draggedDistance >= 0 {
        draggedDistance = 0
        translation.y += bottomConstraintValue
      } else if draggedDistance <= -1 * thumbViewBottomValue {
        draggedDistance = -1 * thumbViewBottomValue
        translation.y += bottomConstraintValue + thumbViewBottomValue
      } else {
        translation.y = 0
      }
      updateBottomConstraint(draggedDistance)
      self.panGestureRecognizer.setTranslation(translation, in: self)
      calculateCurrentValue()
    default:
      break
    }
  }

  private func updateBottomConstraint(_ y: CGFloat) {
    bottomConstraint?.constant = y
    self.setNeedsLayout()
  }

  private func calculateCurrentValue() {
    let minValue: Double = 1
    let maxValue: Double = 0
    let thumbValue = thumbView.frame.midY

    let relative = (thumbValue - 0) / bounds.height
    let value = Float(minValue + (maxValue - minValue) * relative)
    delegate?.soundValueChanged(value)
  }
}


private final class SoundControlSliderThumb: UIView {
  private let label: UILabel = .create { label in
    label.font = .systemFont(ofSize: 11)
    label.textColor = .black
    label.textAlignment = .center
    label.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
  }

  init() {
    super.init(frame: .zero)
    setupViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    addSubview(label)

    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    backgroundColor = .green
    layer.cornerRadius = 4
    label.text = "громкость"
  }
}
