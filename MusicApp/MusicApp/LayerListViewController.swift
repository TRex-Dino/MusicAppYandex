//
//  LayerListViewController.swift
//  MusicApp
//
//  Created by Dmitry Menkov on 05.11.2023.
//

import UIKit

final class LayerListViewController: UIViewController {
  
  weak var delegate: TrackCollectionViewCellDelegate?

  private let collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 7
    return layout
  }()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)


  private var tracks = [TrackModel]()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  func setTracks(_ tracks: [TrackModel]) {
    self.tracks = tracks
    collectionView.reloadData()
  }

  private func setupViews() {
    view.addSubview(collectionView)
    collectionView.backgroundColor = .clear
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
  }
}

extension LayerListViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    tracks.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as! TrackCollectionViewCell
    cell.delegate = delegate
    cell.setTrackName(tracks[indexPath.item].name, index: indexPath.item)
    cell.contentColor(isActive: tracks[indexPath.item].isActive)
    return cell
  }
}

extension LayerListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.trackDidTapped(at: indexPath.item)
  }
}

extension LayerListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width, height: 39)
  }
}
