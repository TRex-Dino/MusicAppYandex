//
//  UIView+Extensions.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 04.11.2023.
//

import UIKit

extension UIView {
  public static func create<T: UIView>(_ apply: (T) -> Void) -> T {
    let view = T()
    apply(view)
    return view
  }
}
