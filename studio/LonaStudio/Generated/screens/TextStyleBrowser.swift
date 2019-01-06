import AppKit
import Foundation

// MARK: - TextStyleBrowser

public class TextStyleBrowser: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(textStyles: TextStyleList) {
    self.init(Parameters(textStyles: textStyles))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var onSelectTextStyle: TextStyleHandler {
    get { return parameters.onSelectTextStyle }
    set { parameters.onSelectTextStyle = newValue }
  }

  public var onDeleteTextStyle: TextStyleHandler {
    get { return parameters.onDeleteTextStyle }
    set { parameters.onDeleteTextStyle = newValue }
  }

  public var textStyles: TextStyleList {
    get { return parameters.textStyles }
    set {
      if parameters.textStyles != newValue {
        parameters.textStyles = newValue
      }
    }
  }

  public var onClickAddTextStyle: (() -> Void)? {
    get { return parameters.onClickAddTextStyle }
    set { parameters.onClickAddTextStyle = newValue }
  }

  public var onMoveTextStyle: ItemMoveHandler {
    get { return parameters.onMoveTextStyle }
    set { parameters.onMoveTextStyle = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var innerView = NSBox()
  private var headerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var spacerView = NSBox()
  private var fixedHeightFixButtonContainerView = NSBox()
  private var addTextStyleButtonView = Button()
  private var textStylePreviewCollectionView = TextStylePreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    headerView.boxType = .custom
    headerView.borderType = .noBorder
    headerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero
    fixedHeightFixButtonContainerView.boxType = .custom
    fixedHeightFixButtonContainerView.borderType = .noBorder
    fixedHeightFixButtonContainerView.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(headerView)
    innerView.addSubview(textStylePreviewCollectionView)
    headerView.addSubview(titleView)
    headerView.addSubview(spacerView)
    headerView.addSubview(fixedHeightFixButtonContainerView)
    fixedHeightFixButtonContainerView.addSubview(addTextStyleButtonView)

    fillColor = Colors.contentBackground
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Text Styles")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    addTextStyleButtonView.titleText = "Add Text Style"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    textStylePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    fixedHeightFixButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
    addTextStyleButtonView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let headerViewTopAnchorConstraint = headerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let headerViewLeadingAnchorConstraint = headerView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let headerViewTrailingAnchorConstraint = headerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let textStylePreviewCollectionViewBottomAnchorConstraint = textStylePreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let textStylePreviewCollectionViewTopAnchorConstraint = textStylePreviewCollectionView
      .topAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let textStylePreviewCollectionViewLeadingAnchorConstraint = textStylePreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
    let textStylePreviewCollectionViewTrailingAnchorConstraint = textStylePreviewCollectionView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor)
    let headerViewHeightAnchorConstraint = headerView.heightAnchor.constraint(equalToConstant: 38)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: headerView.leadingAnchor, constant: 64)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: headerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let spacerViewCenterYAnchorConstraint = spacerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
    let fixedHeightFixButtonContainerViewTrailingAnchorConstraint = fixedHeightFixButtonContainerView
      .trailingAnchor
      .constraint(equalTo: headerView.trailingAnchor, constant: -64)
    let fixedHeightFixButtonContainerViewLeadingAnchorConstraint = fixedHeightFixButtonContainerView
      .leadingAnchor
      .constraint(equalTo: spacerView.trailingAnchor)
    let fixedHeightFixButtonContainerViewTopAnchorConstraint = fixedHeightFixButtonContainerView
      .topAnchor
      .constraint(equalTo: headerView.topAnchor)
    let fixedHeightFixButtonContainerViewCenterYAnchorConstraint = fixedHeightFixButtonContainerView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor)
    let fixedHeightFixButtonContainerViewBottomAnchorConstraint = fixedHeightFixButtonContainerView
      .bottomAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 0)
    let addTextStyleButtonViewWidthAnchorParentConstraint = addTextStyleButtonView
      .widthAnchor
      .constraint(lessThanOrEqualTo: fixedHeightFixButtonContainerView.widthAnchor)
    let addTextStyleButtonViewTopAnchorConstraint = addTextStyleButtonView
      .topAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.topAnchor)
    let addTextStyleButtonViewBottomAnchorConstraint = addTextStyleButtonView
      .bottomAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.bottomAnchor)
    let addTextStyleButtonViewLeadingAnchorConstraint = addTextStyleButtonView
      .leadingAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.leadingAnchor)
    let addTextStyleButtonViewTrailingAnchorConstraint = addTextStyleButtonView
      .trailingAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.trailingAnchor)

    addTextStyleButtonViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      headerViewTopAnchorConstraint,
      headerViewLeadingAnchorConstraint,
      headerViewTrailingAnchorConstraint,
      textStylePreviewCollectionViewBottomAnchorConstraint,
      textStylePreviewCollectionViewTopAnchorConstraint,
      textStylePreviewCollectionViewLeadingAnchorConstraint,
      textStylePreviewCollectionViewTrailingAnchorConstraint,
      headerViewHeightAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewCenterYAnchorConstraint,
      fixedHeightFixButtonContainerViewTrailingAnchorConstraint,
      fixedHeightFixButtonContainerViewLeadingAnchorConstraint,
      fixedHeightFixButtonContainerViewTopAnchorConstraint,
      fixedHeightFixButtonContainerViewCenterYAnchorConstraint,
      fixedHeightFixButtonContainerViewBottomAnchorConstraint,
      spacerViewHeightAnchorConstraint,
      addTextStyleButtonViewWidthAnchorParentConstraint,
      addTextStyleButtonViewTopAnchorConstraint,
      addTextStyleButtonViewBottomAnchorConstraint,
      addTextStyleButtonViewLeadingAnchorConstraint,
      addTextStyleButtonViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    textStylePreviewCollectionView.onSelectTextStyle = handleOnSelectTextStyle
    textStylePreviewCollectionView.onDeleteTextStyle = handleOnDeleteTextStyle
    textStylePreviewCollectionView.onMoveTextStyle = handleOnMoveTextStyle
    textStylePreviewCollectionView.textStyles = textStyles
    addTextStyleButtonView.onClick = handleOnClickAddTextStyle
  }

  private func handleOnSelectTextStyle(_ arg0: CSTextStyle?) {
    onSelectTextStyle?(arg0)
  }

  private func handleOnDeleteTextStyle(_ arg0: CSTextStyle?) {
    onDeleteTextStyle?(arg0)
  }

  private func handleOnClickAddTextStyle() {
    onClickAddTextStyle?()
  }

  private func handleOnMoveTextStyle(_ arg0: Int, _ arg1: Int) {
    onMoveTextStyle?(arg0, arg1)
  }
}

// MARK: - Parameters

extension TextStyleBrowser {
  public struct Parameters: Equatable {
    public var textStyles: TextStyleList
    public var onSelectTextStyle: TextStyleHandler
    public var onDeleteTextStyle: TextStyleHandler
    public var onClickAddTextStyle: (() -> Void)?
    public var onMoveTextStyle: ItemMoveHandler

    public init(
      textStyles: TextStyleList,
      onSelectTextStyle: TextStyleHandler = nil,
      onDeleteTextStyle: TextStyleHandler = nil,
      onClickAddTextStyle: (() -> Void)? = nil,
      onMoveTextStyle: ItemMoveHandler = nil)
    {
      self.textStyles = textStyles
      self.onSelectTextStyle = onSelectTextStyle
      self.onDeleteTextStyle = onDeleteTextStyle
      self.onClickAddTextStyle = onClickAddTextStyle
      self.onMoveTextStyle = onMoveTextStyle
    }

    public init() {
      self.init(textStyles: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.textStyles == rhs.textStyles
    }
  }
}

// MARK: - Model

extension TextStyleBrowser {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TextStyleBrowser"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      textStyles: TextStyleList,
      onSelectTextStyle: TextStyleHandler = nil,
      onDeleteTextStyle: TextStyleHandler = nil,
      onClickAddTextStyle: (() -> Void)? = nil,
      onMoveTextStyle: ItemMoveHandler = nil)
    {
      self
        .init(
          Parameters(
            textStyles: textStyles,
            onSelectTextStyle: onSelectTextStyle,
            onDeleteTextStyle: onDeleteTextStyle,
            onClickAddTextStyle: onClickAddTextStyle,
            onMoveTextStyle: onMoveTextStyle))
    }

    public init() {
      self.init(textStyles: [])
    }
  }
}
