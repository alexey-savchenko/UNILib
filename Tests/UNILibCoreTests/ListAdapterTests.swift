import UIKit
import XCTest
@testable import UNILibCore

@MainActor
final class ListAdapterTests: XCTestCase {
    /// Shrinking the list while the flow layout is invalid made `prepareLayout` ask for sizes of the old item
    /// count after `elements` already held the new, shorter array ("Index out of range").
    func testShrinkingWhileTheLayoutIsInvalidDoesNotCrash() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 390, height: 844),
            collectionViewLayout: layout
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let window = UIWindow(frame: collectionView.frame)
        window.addSubview(collectionView)
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        var sizedItems: [Int] = []
        let adapter = SimpleListAdapter<Int>(
            bind: collectionView,
            builder: { collectionView, indexPath, _ in
                collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            },
            sizing: { item, _ in
                sizedItems.append(item)
                return collectionView.bounds.size
            }
        )
        adapter.shouldAnimate = false

        adapter.pushElements(Array(0..<12))
        collectionView.layoutIfNeeded()

        layout.invalidateLayout()
        adapter.pushElements(Array(0..<11))
        collectionView.layoutIfNeeded()

        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 11)
        XCTAssertFalse(sizedItems.isEmpty)
    }
}
