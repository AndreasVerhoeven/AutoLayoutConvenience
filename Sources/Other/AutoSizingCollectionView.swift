//
//  AutoSizingCollectionView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 10/05/2022.
//

import UIKit

/// A UICollectionView with its intrinsic content size the same as the contentSize
public class AutoSizingCollectionView: UICollectionView {
	public override var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			invalidateIntrinsicContentSize()
		}
	}
	public override var intrinsicContentSize: CGSize { contentSize }
}
