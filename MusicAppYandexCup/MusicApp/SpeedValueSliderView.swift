//
//  SpeedValueSliderView.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 04.11.2023.
//

import UIKit

protocol SpeedValueSliderViewDelegate: AnyObject {
  func speedValueChanged(_ value: Float)
}

final class SpeedValueSliderView: UIView {
  
  weak var delegate: SpeedValueSliderViewDelegate?
  
  private let thumbView = SpeedValueThumb()
  
  override class var layerClass: AnyClass {
    return CAShapeLayer.self
  }
  
  private var leadingConstraint: NSLayoutConstraint?
  private var panGestureRecognizer: UIPanGestureRecognizer!
  private var thumbViewLeadingValue: CGFloat {
    bounds.width - thumbView.bounds.width
  }
  
  init() {
    super.init(frame: .zero)
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
    var x: CGFloat = 1
    
    while x <= bounds.width {
      let offset: CGFloat
      if x/bounds.width <= 0.3 {
        offset = 9
      } else if x/bounds.width <= 0.5 {
        offset = 7
      } else if x/bounds.width <= 0.7 {
        offset = 6
      } else if x/bounds.width <= 0.85 {
        offset = 5
      } else {
        offset = 3
      }
      bezier.move(to: CGPoint(x: x, y: bounds.height))
      bezier.addLine(to: CGPoint(x: x, y: 0))
      x += (lineWidth + offset)
    }
    
    let shapeLayer = self.layer as! CAShapeLayer
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.masksToBounds = true
    
    shapeLayer.path = bezier.cgPath
  }
  
  private func setupView() {
    backgroundColor = .clear
    addSubview(thumbView)
    leadingConstraint = thumbView.leadingAnchor.constraint(equalTo: leadingAnchor)
    leadingConstraint?.isActive = true
    
    thumbView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.size.equalTo(CGSize(width: 64, height: 14))
    }
  }
  
  private func addGestures() {
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGestureRecognizer.minimumNumberOfTouches = 0
    thumbView.addGestureRecognizer(panGestureRecognizer)
  }
  
  @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    guard let leadingConstraintValue = leadingConstraint?.constant else {
      return
    }
    var translation = sender.translation(in: self)
    switch sender.state {
    case .changed:
      var draggedDistance: CGFloat = leadingConstraintValue + translation.x
      if draggedDistance >= thumbViewLeadingValue {
        draggedDistance = thumbViewLeadingValue
        translation.x += leadingConstraintValue - thumbViewLeadingValue
      } else if draggedDistance <= .zero {
        draggedDistance = .zero
        translation.x += leadingConstraintValue
      } else {
        translation.x = .zero
      }
      updateLeadingConstraint(draggedDistance)
      self.panGestureRecognizer.setTranslation(translation, in: self)
      calculateCurrentValue()
    default:
      break
    }
  }
  
  private func updateLeadingConstraint(_ x: CGFloat) {
    leadingConstraint?.constant = x
    self.setNeedsLayout()
  }
  
  private func calculateCurrentValue() {
    let minValue: Double
    let maxValue: Double
    
    let thumbValue = thumbView.frame.midX
    var width = bounds.width
    var minWidthValue: Double = 0
    
    if thumbValue <= width/2 {
      minValue = 1/32
      maxValue = 1
      width /= 2
    } else {
      minValue = 1
      maxValue = 32
      minWidthValue = width/2
    }
    
    let relative = (thumbValue - minWidthValue) / width
    let currentValue = minValue + (maxValue - minValue) * relative
    delegate?.speedValueChanged(Float(currentValue))
  }
}


private final class SpeedValueThumb: UIView {
  private let label: UILabel = .create { label in
    label.font = .systemFont(ofSize: 11)
    label.textColor = .black
    label.textAlignment = .center
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
      make.leading.trailing.equalToSuperview().inset(7)
      make.centerY.equalToSuperview()
    }
    backgroundColor = .green
    layer.cornerRadius = 4
    label.text = "скорость"
  }
}
