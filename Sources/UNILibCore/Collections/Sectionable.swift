import Foundation

/// A generic, hashable section model for use with diffable data sources.
///
/// This struct holds a unique section identifier and a collection of hashable elements,
/// making it suitable for representing sections in `UICollectionView` or `UITableView`.
///
/// - Parameters:
///   - SectionID: The type for the unique identifier of the section, which must be `Hashable`.
///   - Element: The type for the elements within the section, which must be `Hashable`.
public struct Sectionable<SectionID: Hashable, Element: Hashable>: Hashable {
    /// A unique identifier for the section.
    public let id: SectionID
    /// An array of elements contained within the section.
    public let elements: [Element]

    /// Initializes a new section with a unique identifier and its elements.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the section.
    ///   - elements: The array of hashable elements in the section.
    public init(id: SectionID, elements: [Element]) {
        self.id = id
        self.elements = elements
    }
}
