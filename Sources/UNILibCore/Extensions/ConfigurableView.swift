import UIKit

public protocol ConfigurableView {
    associatedtype Model
    func configure(with model: Model)
}

public extension ConfigurableView where Self: UICollectionViewCell {
    @MainActor
    static func sizeWith(bounding width: CGFloat, model: Model) -> CGSize {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let cell = Self(frame: .init(origin: .zero, size: size))
        cell.configure(with: model)
        cell.layoutIfNeeded()
        let fittingSize = cell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: fittingSize.height)
    }
}
