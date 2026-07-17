import UIKit

/// An adapter for `UICollectionView` that simplifies using `UICollectionViewDiffableDataSource`.
/// This class manages data sections, cell configuration, sizing, and delegate callbacks for selection and layout.
public class ListAdapter<
    SectionID: Sendable & Hashable,
    Element: Sendable & Hashable
>: NSObject, UICollectionViewDelegateFlowLayout {
    /// A type alias for a closure that provides supplementary views, such as headers or footers.
    /// - Parameters:
    ///   - collectionView: The collection view requesting the view.
    ///   - kind: The kind of supplementary view to provide.
    ///   - indexPath: The index path for the supplementary view.
    ///   - section: The section data associated with the supplementary view.
    /// - Returns: A configured `UICollectionReusableView` or `nil`.
    public typealias SupplementaryProvider = (UICollectionView, String, IndexPath, Sectionable<SectionID, Element>) -> UICollectionReusableView?
    
    private let build: (UICollectionView, IndexPath, Element) -> UICollectionViewCell
    /// The current data source for the collection view, represented as an array of `Sectionable` items.
    public var elements: [Sectionable<SectionID, Element>] = []
    private let sizing: ((Element, IndexPath) -> CGSize)?
    private let cv: UICollectionView
    private let supplementaryProvider: SupplementaryProvider?
    private let headerSizeProvider: ((Int, Sectionable<SectionID, Element>) -> CGSize)?
    
    /// A closure to be executed when an item in the collection view is selected.
    public var didSelectItem: ((Element) -> Void)?
    /// A closure to be executed when an item is moved from a source `IndexPath` to a destination `IndexPath`.
    public var didMoveItem: ((IndexPath, IndexPath) -> Void)?
    /// A closure that returns the insets for a specific section.
    public var insetForSectionAt: ((Int) -> UIEdgeInsets)?
    
    /// Determines whether updates to the collection view are animated. Default is `true`.
    public var shouldAnimate = true
    
    private let ds: UICollectionViewDiffableDataSource<SectionID, Element>
    
    /// Initializes a `ListAdapter`.
    /// - Parameters:
    ///   - cv: The `UICollectionView` to be managed by this adapter.
    ///   - builder: A closure that configures and returns a `UICollectionViewCell` for a given element and `IndexPath`.
    ///   - sizing: An optional closure that calculates the size for an item at a given `IndexPath`.
    ///   - supplementaryProvider: An optional closure that provides supplementary views (e.g., headers).
    ///   - headerSizeProvider: An optional closure that provides the size for section headers.
    public init(
        bind cv: UICollectionView,
        builder: @escaping (UICollectionView, IndexPath, Element) -> UICollectionViewCell,
        sizing: ((Element, IndexPath) -> CGSize)?,
        supplementaryProvider: SupplementaryProvider? = nil,
        headerSizeProvider: ((Int, Sectionable<SectionID, Element>) -> CGSize)? = nil
    ) {
        build = builder
        self.cv = cv
        self.sizing = sizing
        self.supplementaryProvider = supplementaryProvider
        self.headerSizeProvider = headerSizeProvider
        self.ds = UICollectionViewDiffableDataSource<SectionID, Element>(
            collectionView: cv,
            cellProvider: builder
        )
        super.init()
        
        cv.delegate = self
        ds.supplementaryViewProvider = { [unowned self] collectionView, kind, indexPath in
            let section = self.elements[indexPath.section]
            return self.supplementaryProvider?(collectionView, kind, indexPath, section)
        }
    }
    
    /// Updates the collection view with a new set of sections.
    /// - Parameter sections: An array of `Sectionable` items to display.
    public func pushElements(_ sections: [Sectionable<SectionID, Element>]) {
        self.elements = sections
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, Element>()
        snapshot.appendSections(sections.map { $0.id })
        sections.forEach { section in
            snapshot.appendItems(section.elements, toSection: section.id)
        }
        
        ds.apply(snapshot, animatingDifferences: shouldAnimate)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        sizing?(elements[indexPath.section].elements[indexPath.item], indexPath) ?? .zero
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        didSelectItem?(elements[indexPath.section].elements[indexPath.item])
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        didMoveItem?(sourceIndexPath, destinationIndexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return insetForSectionAt?(section) ?? .zero
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return headerSizeProvider?(section, elements[section]) ?? .zero
    }
}

// MARK: - Single Section Convenience

public class SimpleListAdapter<Element: Sendable & Hashable>: ListAdapter<String, Element> {
    public func pushElements(_ values: [Element]) {
        let section = Sectionable(id: "", elements: values)
        pushElements([section])
    }
}
