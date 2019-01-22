
import UIKit

// MARK: - LonaCollectionViewCell

public class LonaCollectionViewCell<T: UIView>: UICollectionViewCell {

  // MARK: Lifecycle

  override public init(frame: CGRect) {
    super.init(frame: frame)

    setUpViews()
    setUpConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var view: T = T()

  public var scrollDirection = UICollectionView.ScrollDirection.vertical

  override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutIfNeeded()

    let preferredLayoutAttributes =
      super.preferredLayoutAttributesFitting(layoutAttributes)
    preferredLayoutAttributes.bounds = layoutAttributes.bounds

    switch scrollDirection {
    case .vertical:
      preferredLayoutAttributes.bounds.size.height = systemLayoutSizeFitting(
        UILayoutFittingCompressedSize,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .defaultLow).height
    case .horizontal:
      preferredLayoutAttributes.bounds.size.width = systemLayoutSizeFitting(
        UILayoutFittingCompressedSize,
        withHorizontalFittingPriority: .defaultLow,
        verticalFittingPriority: .required).width
    }

    return preferredLayoutAttributes
  }

  // MARK: Private

  private func setUpViews() {
    contentView.addSubview(view)
  }

  private func setUpConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

    let width = contentView.widthAnchor.constraint(equalTo: widthAnchor)
    width.priority = .required - 1
    width.isActive = true

    let height = contentView.heightAnchor.constraint(equalTo: heightAnchor)
    height.priority = .required - 1
    height.isActive = true

    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
  }

}

// MARK: - LonaCollectionViewListLayout

public class LonaCollectionViewListLayout: UICollectionViewFlowLayout {
  override public init() {
    super.init()

    self.minimumInteritemSpacing = 0
    self.minimumLineSpacing = 0
    self.sectionInset = .zero
    self.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath),
      let collectionView = collectionView else { return nil }

    switch scrollDirection {
    case .vertical:
      layoutAttributes.bounds.size.width =
        collectionView.safeAreaLayoutGuide.layoutFrame.width -
        sectionInset.left - sectionInset.right -
        collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
    case .horizontal:
      layoutAttributes.bounds.size.height =
        collectionView.safeAreaLayoutGuide.layoutFrame.height -
        sectionInset.top - sectionInset.bottom -
        collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
    }

    return layoutAttributes
  }

  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

    let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
      return layoutAttribute.representedElementCategory == .cell
        ? layoutAttributesForItem(at: layoutAttribute.indexPath)
        : layoutAttribute
    }

    return computedAttributes
  }
}

// MARK: - LonaCollectionView

public class LonaCollectionView: UICollectionView,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout {

  // MARK: Lifecycle

  private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    parameters = Parameters()

    super.init(frame: frame, collectionViewLayout: LonaCollectionViewListLayout())

    contentInsetAdjustmentBehavior = .automatic
    backgroundColor = .clear

    delegate = self
    dataSource = self

    register(LonaNestedCollectionViewCell.self, forCellWithReuseIdentifier: LonaNestedCollectionViewCell.identifier)
    
    register(NestedBottomLeftLayoutCell.self, forCellWithReuseIdentifier: NestedBottomLeftLayoutCell.identifier)
    register(NestedButtonsCell.self, forCellWithReuseIdentifier: NestedButtonsCell.identifier)
    register(NestedComponentCell.self, forCellWithReuseIdentifier: NestedComponentCell.identifier)
    register(NestedLayoutCell.self, forCellWithReuseIdentifier: NestedLayoutCell.identifier)
    register(NestedOptionalsCell.self, forCellWithReuseIdentifier: NestedOptionalsCell.identifier)
    register(ImageCroppingCell.self, forCellWithReuseIdentifier: ImageCroppingCell.identifier)
    register(LocalAssetCell.self, forCellWithReuseIdentifier: LocalAssetCell.identifier)
    register(VectorAssetCell.self, forCellWithReuseIdentifier: VectorAssetCell.identifier)
    register(AccessibilityTestCell.self, forCellWithReuseIdentifier: AccessibilityTestCell.identifier)
    register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.identifier)
    register(PressableRootViewCell.self, forCellWithReuseIdentifier: PressableRootViewCell.identifier)
    register(FillWidthFitHeightCardCell.self, forCellWithReuseIdentifier: FillWidthFitHeightCardCell.identifier)
    register(
      FitContentParentSecondaryChildrenCell.self,
      forCellWithReuseIdentifier: FitContentParentSecondaryChildrenCell.identifier)
    register(
      FixedParentFillAndFitChildrenCell.self,
      forCellWithReuseIdentifier: FixedParentFillAndFitChildrenCell.identifier)
    register(FixedParentFitChildCell.self, forCellWithReuseIdentifier: FixedParentFitChildCell.identifier)
    register(MultipleFlexTextCell.self, forCellWithReuseIdentifier: MultipleFlexTextCell.identifier)
    register(PrimaryAxisCell.self, forCellWithReuseIdentifier: PrimaryAxisCell.identifier)
    register(
      PrimaryAxisFillNestedSiblingsCell.self,
      forCellWithReuseIdentifier: PrimaryAxisFillNestedSiblingsCell.identifier)
    register(PrimaryAxisFillSiblingsCell.self, forCellWithReuseIdentifier: PrimaryAxisFillSiblingsCell.identifier)
    register(SecondaryAxisCell.self, forCellWithReuseIdentifier: SecondaryAxisCell.identifier)
    register(AssignCell.self, forCellWithReuseIdentifier: AssignCell.identifier)
    register(IfCell.self, forCellWithReuseIdentifier: IfCell.identifier)
    register(OptionalsCell.self, forCellWithReuseIdentifier: OptionalsCell.identifier)
    register(RepeatedVectorCell.self, forCellWithReuseIdentifier: RepeatedVectorCell.identifier)
    register(VectorLogicCell.self, forCellWithReuseIdentifier: VectorLogicCell.identifier)
    register(BorderStyleTestCell.self, forCellWithReuseIdentifier: BorderStyleTestCell.identifier)
    register(BorderWidthColorCell.self, forCellWithReuseIdentifier: BorderWidthColorCell.identifier)
    register(BoxModelConditionalCell.self, forCellWithReuseIdentifier: BoxModelConditionalCell.identifier)
    register(InlineVariantTestCell.self, forCellWithReuseIdentifier: InlineVariantTestCell.identifier)
    register(OpacityTestCell.self, forCellWithReuseIdentifier: OpacityTestCell.identifier)
    register(ShadowsTestCell.self, forCellWithReuseIdentifier: ShadowsTestCell.identifier)
    register(TextAlignmentCell.self, forCellWithReuseIdentifier: TextAlignmentCell.identifier)
    register(TextStyleConditionalCell.self, forCellWithReuseIdentifier: TextStyleConditionalCell.identifier)
    register(TextStylesTestCell.self, forCellWithReuseIdentifier: TextStylesTestCell.identifier)
    register(VisibilityTestCell.self, forCellWithReuseIdentifier: VisibilityTestCell.identifier)
  }

  public convenience init(
    _ parameters: Parameters = Parameters(),
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {
    self.init(frame: .zero, collectionViewLayout: layout)

    let oldParameters = self.parameters
    self.parameters = parameters

    parametersDidChange(oldValue: oldParameters)
  }

  public convenience init(
    items: [LonaViewModel] = [],
    scrollDirection: UICollectionView.ScrollDirection = .vertical,
    padding: UIEdgeInsets = .zero,
    itemSpacing: CGFloat = 0,
    fixedSize: CGFloat? = nil,
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {
    self.init(
      Parameters(
        items: items,
        scrollDirection: scrollDirection,
        padding: padding,
        itemSpacing: itemSpacing,
        fixedSize: fixedSize),
      collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var parameters: Parameters {
    didSet {
      parametersDidChange(oldValue: oldValue)
    }
  }

  public var items: [LonaViewModel] {
    get { return parameters.items }
    set { parameters.items = newValue }
  }

  public var scrollDirection: UICollectionView.ScrollDirection {
    get { return parameters.scrollDirection }
    set { parameters.scrollDirection = newValue }
  }

  // MARK: Data Source

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let item = items[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.type, for: indexPath)
    let scrollDirection = self.scrollDirection

    switch (item.type) {
    case LonaNestedCollectionViewCell.identifier:
      if let cell = cell as? LonaNestedCollectionViewCell, let item = item as? LonaCollectionView.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
        cell.view.onSelectItem = onSelectItem
      }
    case NestedBottomLeftLayoutCell.identifier:
      if let cell = cell as? NestedBottomLeftLayoutCell, let item = item as? NestedBottomLeftLayout.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case NestedButtonsCell.identifier:
      if let cell = cell as? NestedButtonsCell, let item = item as? NestedButtons.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case NestedComponentCell.identifier:
      if let cell = cell as? NestedComponentCell, let item = item as? NestedComponent.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case NestedLayoutCell.identifier:
      if let cell = cell as? NestedLayoutCell, let item = item as? NestedLayout.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case NestedOptionalsCell.identifier:
      if let cell = cell as? NestedOptionalsCell, let item = item as? NestedOptionals.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case ImageCroppingCell.identifier:
      if let cell = cell as? ImageCroppingCell, let item = item as? ImageCropping.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case LocalAssetCell.identifier:
      if let cell = cell as? LocalAssetCell, let item = item as? LocalAsset.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case VectorAssetCell.identifier:
      if let cell = cell as? VectorAssetCell, let item = item as? VectorAsset.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case AccessibilityTestCell.identifier:
      if let cell = cell as? AccessibilityTestCell, let item = item as? AccessibilityTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case ButtonCell.identifier:
      if let cell = cell as? ButtonCell, let item = item as? Button.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
        cell.view.isEnabled = false
      }
    case PressableRootViewCell.identifier:
      if let cell = cell as? PressableRootViewCell, let item = item as? PressableRootView.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
        cell.view.isRootControlTrackingEnabled = false
      }
    case FillWidthFitHeightCardCell.identifier:
      if let cell = cell as? FillWidthFitHeightCardCell, let item = item as? FillWidthFitHeightCard.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case FitContentParentSecondaryChildrenCell.identifier:
      if
      let cell = cell as? FitContentParentSecondaryChildrenCell, let item = item as? FitContentParentSecondaryChildren.Model
      {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case FixedParentFillAndFitChildrenCell.identifier:
      if let cell = cell as? FixedParentFillAndFitChildrenCell, let item = item as? FixedParentFillAndFitChildren.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case FixedParentFitChildCell.identifier:
      if let cell = cell as? FixedParentFitChildCell, let item = item as? FixedParentFitChild.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case MultipleFlexTextCell.identifier:
      if let cell = cell as? MultipleFlexTextCell, let item = item as? MultipleFlexText.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case PrimaryAxisCell.identifier:
      if let cell = cell as? PrimaryAxisCell, let item = item as? PrimaryAxis.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case PrimaryAxisFillNestedSiblingsCell.identifier:
      if let cell = cell as? PrimaryAxisFillNestedSiblingsCell, let item = item as? PrimaryAxisFillNestedSiblings.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case PrimaryAxisFillSiblingsCell.identifier:
      if let cell = cell as? PrimaryAxisFillSiblingsCell, let item = item as? PrimaryAxisFillSiblings.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case SecondaryAxisCell.identifier:
      if let cell = cell as? SecondaryAxisCell, let item = item as? SecondaryAxis.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case AssignCell.identifier:
      if let cell = cell as? AssignCell, let item = item as? Assign.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case IfCell.identifier:
      if let cell = cell as? IfCell, let item = item as? If.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case OptionalsCell.identifier:
      if let cell = cell as? OptionalsCell, let item = item as? Optionals.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case RepeatedVectorCell.identifier:
      if let cell = cell as? RepeatedVectorCell, let item = item as? RepeatedVector.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case VectorLogicCell.identifier:
      if let cell = cell as? VectorLogicCell, let item = item as? VectorLogic.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case BorderStyleTestCell.identifier:
      if let cell = cell as? BorderStyleTestCell, let item = item as? BorderStyleTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case BorderWidthColorCell.identifier:
      if let cell = cell as? BorderWidthColorCell, let item = item as? BorderWidthColor.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case BoxModelConditionalCell.identifier:
      if let cell = cell as? BoxModelConditionalCell, let item = item as? BoxModelConditional.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case InlineVariantTestCell.identifier:
      if let cell = cell as? InlineVariantTestCell, let item = item as? InlineVariantTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case OpacityTestCell.identifier:
      if let cell = cell as? OpacityTestCell, let item = item as? OpacityTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case ShadowsTestCell.identifier:
      if let cell = cell as? ShadowsTestCell, let item = item as? ShadowsTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case TextAlignmentCell.identifier:
      if let cell = cell as? TextAlignmentCell, let item = item as? TextAlignment.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case TextStyleConditionalCell.identifier:
      if let cell = cell as? TextStyleConditionalCell, let item = item as? TextStyleConditional.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case TextStylesTestCell.identifier:
      if let cell = cell as? TextStylesTestCell, let item = item as? TextStylesTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    case VisibilityTestCell.identifier:
      if let cell = cell as? VisibilityTestCell, let item = item as? VisibilityTest.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
      }
    default:
      break
    }

    return cell
  }

  // MARK: Delegate

  public var onSelectItem: ((Int) -> Void)?

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let cell = cellForItem(at: indexPath)

    switch (item.type) {
    case ButtonCell.identifier:
      if let cell = cell as? ButtonCell {
        cell.view.sendActions(for: .touchUpInside)
      }
    case PressableRootViewCell.identifier:
      if let cell = cell as? PressableRootViewCell {
        cell.view.sendActions(for: .touchUpInside)
      }
    default:
      break
    }

    onSelectItem?(indexPath.item)
  }

  // MARK: Layout

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch scrollDirection {
    case .horizontal:
      return CGSize(width: 50, height: collectionView.safeAreaLayoutGuide.layoutFrame.height)
    case .vertical:
      return CGSize(width: collectionView.safeAreaLayoutGuide.layoutFrame.width, height: 50)
    }
  }

  // MARK: Scrolling

  override public func touchesShouldCancel(in view: UIView) -> Bool {
    if view is LonaControl {
      return true
    }

    return super.touchesShouldCancel(in: view)
  }

  // MARK: Private

  private func updateAlwaysBounce(for scrollDirection: ScrollDirection) {
    alwaysBounceVertical = scrollDirection == .vertical
    alwaysBounceHorizontal = scrollDirection == .horizontal
  }

  private func parametersDidChange(oldValue: Parameters) {
    updateAlwaysBounce(for: parameters.scrollDirection)
    contentInset = parameters.padding

    switch parameters.scrollDirection {
    case .horizontal:
      showsHorizontalScrollIndicator = false
    case .vertical:
      showsHorizontalScrollIndicator = true
    }
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = parameters.itemSpacing
      layout.scrollDirection = parameters.scrollDirection
      layout.invalidateLayout()
    }

    reloadData()
    layoutIfNeeded()

    contentOffset = CGPoint(
      x: contentOffset.x - parameters.padding.left + oldValue.padding.left,
      y: contentOffset.y - parameters.padding.top + oldValue.padding.top)
  }
}


// MARK: - Parameters

extension LonaCollectionView {
  public struct Parameters {
    public var items: [LonaViewModel]
    public var scrollDirection: UICollectionView.ScrollDirection
    public var padding: UIEdgeInsets
    public var itemSpacing: CGFloat
    public var fixedSize: CGFloat?

    public init(
      items: [LonaViewModel],
      scrollDirection: UICollectionView.ScrollDirection,
      padding: UIEdgeInsets,
      itemSpacing: CGFloat,
      fixedSize: CGFloat? = nil)
    {
      self.items = items
      self.scrollDirection = scrollDirection
      self.padding = padding
      self.itemSpacing = itemSpacing
      self.fixedSize = fixedSize
    }

    public init() {
      self.init(items: [], scrollDirection: .vertical, padding: .zero, itemSpacing: 0)
    }
  }
}

// MARK: - Model

extension LonaCollectionView {
  public struct Model: LonaViewModel {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "LonaCollectionView"
    }

    public init(id: String?, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      items: [LonaViewModel],
      scrollDirection: UICollectionView.ScrollDirection,
      padding: UIEdgeInsets = .zero,
      itemSpacing: CGFloat = 0,
      fixedSize: CGFloat? = nil)
    {
      self.init(
        Parameters(
          items: items,
          scrollDirection: scrollDirection,
          padding: padding,
          itemSpacing: itemSpacing,
          fixedSize: fixedSize))
    }

    public init() {
      self.init(items: [], scrollDirection: .vertical)
    }
  }
}

// MARK: - Cell Classes

public class LonaNestedCollectionViewCell: LonaCollectionViewCell<LonaCollectionView> {
  public var parameters: LonaCollectionView.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "LonaCollectionView"
  }
  override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    let preferredLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

    if let fixedSize = parameters.fixedSize {
      switch scrollDirection {
      case .vertical:
        preferredLayoutAttributes.bounds.size.height = fixedSize
      case .horizontal:
        preferredLayoutAttributes.bounds.size.width = fixedSize
      }
    }

    return preferredLayoutAttributes
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if (contentView.bounds != view.bounds) {
      view.collectionViewLayout.invalidateLayout()
    }
  }
}

public class NestedBottomLeftLayoutCell: LonaCollectionViewCell<NestedBottomLeftLayout> {
  public var parameters: NestedBottomLeftLayout.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "NestedBottomLeftLayout"
  }
}

public class NestedButtonsCell: LonaCollectionViewCell<NestedButtons> {
  public var parameters: NestedButtons.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "NestedButtons"
  }
}

public class NestedComponentCell: LonaCollectionViewCell<NestedComponent> {
  public var parameters: NestedComponent.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "NestedComponent"
  }
}

public class NestedLayoutCell: LonaCollectionViewCell<NestedLayout> {
  public var parameters: NestedLayout.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "NestedLayout"
  }
}

public class NestedOptionalsCell: LonaCollectionViewCell<NestedOptionals> {
  public var parameters: NestedOptionals.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "NestedOptionals"
  }
}

public class ImageCroppingCell: LonaCollectionViewCell<ImageCropping> {
  public var parameters: ImageCropping.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "ImageCropping"
  }
}

public class LocalAssetCell: LonaCollectionViewCell<LocalAsset> {
  public var parameters: LocalAsset.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "LocalAsset"
  }
}

public class VectorAssetCell: LonaCollectionViewCell<VectorAsset> {
  public var parameters: VectorAsset.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "VectorAsset"
  }
}

public class AccessibilityTestCell: LonaCollectionViewCell<AccessibilityTest> {
  public var parameters: AccessibilityTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "AccessibilityTest"
  }
}

public class ButtonCell: LonaCollectionViewCell<Button> {
  public var parameters: Button.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public override var isHighlighted: Bool { didSet { view.isControlPressed = isHighlighted } }
  public static var identifier: String {
    return "Button"
  }
}

public class PressableRootViewCell: LonaCollectionViewCell<PressableRootView> {
  public var parameters: PressableRootView.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public override var isHighlighted: Bool { didSet { view.isControlPressed = isHighlighted } }
  public static var identifier: String {
    return "PressableRootView"
  }
}

public class FillWidthFitHeightCardCell: LonaCollectionViewCell<FillWidthFitHeightCard> {
  public var parameters: FillWidthFitHeightCard.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "FillWidthFitHeightCard"
  }
}

public class FitContentParentSecondaryChildrenCell: LonaCollectionViewCell<FitContentParentSecondaryChildren> {
  public var parameters: FitContentParentSecondaryChildren.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "FitContentParentSecondaryChildren"
  }
}

public class FixedParentFillAndFitChildrenCell: LonaCollectionViewCell<FixedParentFillAndFitChildren> {
  public var parameters: FixedParentFillAndFitChildren.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "FixedParentFillAndFitChildren"
  }
}

public class FixedParentFitChildCell: LonaCollectionViewCell<FixedParentFitChild> {
  public var parameters: FixedParentFitChild.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "FixedParentFitChild"
  }
}

public class MultipleFlexTextCell: LonaCollectionViewCell<MultipleFlexText> {
  public var parameters: MultipleFlexText.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "MultipleFlexText"
  }
}

public class PrimaryAxisCell: LonaCollectionViewCell<PrimaryAxis> {
  public var parameters: PrimaryAxis.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "PrimaryAxis"
  }
}

public class PrimaryAxisFillNestedSiblingsCell: LonaCollectionViewCell<PrimaryAxisFillNestedSiblings> {
  public var parameters: PrimaryAxisFillNestedSiblings.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "PrimaryAxisFillNestedSiblings"
  }
}

public class PrimaryAxisFillSiblingsCell: LonaCollectionViewCell<PrimaryAxisFillSiblings> {
  public var parameters: PrimaryAxisFillSiblings.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "PrimaryAxisFillSiblings"
  }
}

public class SecondaryAxisCell: LonaCollectionViewCell<SecondaryAxis> {
  public var parameters: SecondaryAxis.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "SecondaryAxis"
  }
}

public class AssignCell: LonaCollectionViewCell<Assign> {
  public var parameters: Assign.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "Assign"
  }
}

public class IfCell: LonaCollectionViewCell<If> {
  public var parameters: If.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "If"
  }
}

public class OptionalsCell: LonaCollectionViewCell<Optionals> {
  public var parameters: Optionals.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "Optionals"
  }
}

public class RepeatedVectorCell: LonaCollectionViewCell<RepeatedVector> {
  public var parameters: RepeatedVector.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "RepeatedVector"
  }
}

public class VectorLogicCell: LonaCollectionViewCell<VectorLogic> {
  public var parameters: VectorLogic.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "VectorLogic"
  }
}

public class BorderStyleTestCell: LonaCollectionViewCell<BorderStyleTest> {
  public var parameters: BorderStyleTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "BorderStyleTest"
  }
}

public class BorderWidthColorCell: LonaCollectionViewCell<BorderWidthColor> {
  public var parameters: BorderWidthColor.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "BorderWidthColor"
  }
}

public class BoxModelConditionalCell: LonaCollectionViewCell<BoxModelConditional> {
  public var parameters: BoxModelConditional.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "BoxModelConditional"
  }
}

public class InlineVariantTestCell: LonaCollectionViewCell<InlineVariantTest> {
  public var parameters: InlineVariantTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "InlineVariantTest"
  }
}

public class OpacityTestCell: LonaCollectionViewCell<OpacityTest> {
  public var parameters: OpacityTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "OpacityTest"
  }
}

public class ShadowsTestCell: LonaCollectionViewCell<ShadowsTest> {
  public var parameters: ShadowsTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "ShadowsTest"
  }
}

public class TextAlignmentCell: LonaCollectionViewCell<TextAlignment> {
  public var parameters: TextAlignment.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "TextAlignment"
  }
}

public class TextStyleConditionalCell: LonaCollectionViewCell<TextStyleConditional> {
  public var parameters: TextStyleConditional.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "TextStyleConditional"
  }
}

public class TextStylesTestCell: LonaCollectionViewCell<TextStylesTest> {
  public var parameters: TextStylesTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "TextStylesTest"
  }
}

public class VisibilityTestCell: LonaCollectionViewCell<VisibilityTest> {
  public var parameters: VisibilityTest.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "VisibilityTest"
  }
}