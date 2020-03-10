import AppKit
import Foundation

// MARK: - WorkspaceTemplateCard

public class WorkspaceTemplateCard: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init(titleText: String, descriptionText: String, isSelected: Bool, image: NSImage) {
    self.init(Parameters(titleText: titleText, descriptionText: descriptionText, isSelected: isSelected, image: image))
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

    addTrackingArea(trackingArea)
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var descriptionText: String {
    get { return parameters.descriptionText }
    set {
      if parameters.descriptionText != newValue {
        parameters.descriptionText = newValue
      }
    }
  }

  public var isSelected: Bool {
    get { return parameters.isSelected }
    set {
      if parameters.isSelected != newValue {
        parameters.isSelected = newValue
      }
    }
  }

  public var image: NSImage {
    get { return parameters.image }
    set {
      if parameters.image != newValue {
        parameters.image = newValue
      }
    }
  }

  public var onPressCard: (() -> Void)? {
    get { return parameters.onPressCard }
    set { parameters.onPressCard = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var imageContainerView = NSBox()
  private var imageView = LNAImageView()
  private var titleView = LNATextField(labelWithString: "")
  private var descriptionView = LNATextField(labelWithString: "")

  private var titleViewTextStyle = TextStyles.large
  private var descriptionViewTextStyle = TextStyles.regularMuted

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    imageContainerView.boxType = .custom
    imageContainerView.borderType = .lineBorder
    imageContainerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    descriptionView.lineBreakMode = .byWordWrapping

    addSubview(imageContainerView)
    addSubview(titleView)
    addSubview(descriptionView)
    imageContainerView.addSubview(imageView)

    cornerRadius = 4
    borderWidth = 1
    imageContainerView.fillColor = Colors.dividerSubtle
    imageContainerView.cornerRadius = 8
    imageContainerView.borderWidth = 1
    titleViewTextStyle = TextStyles.large
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    descriptionViewTextStyle = TextStyles.regularMuted
    descriptionView.attributedStringValue = descriptionViewTextStyle.apply(to: descriptionView.attributedStringValue)
    descriptionView.maximumNumberOfLines = 2
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageContainerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    descriptionView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 220)
    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: 216)
    let imageContainerViewTopAnchorConstraint = imageContainerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: 13)
    let imageContainerViewLeadingAnchorConstraint = imageContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 13)
    let imageContainerViewTrailingAnchorConstraint = imageContainerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -13)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: imageContainerView.bottomAnchor, constant: 12)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -13)
    let descriptionViewTopAnchorConstraint = descriptionView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: 8)
    let descriptionViewLeadingAnchorConstraint = descriptionView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 13)
    let descriptionViewTrailingAnchorConstraint = descriptionView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -13)
    let imageContainerViewHeightAnchorConstraint = imageContainerView.heightAnchor.constraint(equalToConstant: 120)
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: imageContainerView.topAnchor, constant: 1)
    let imageViewBottomAnchorConstraint = imageView
      .bottomAnchor
      .constraint(equalTo: imageContainerView.bottomAnchor, constant: -1)
    let imageViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: imageContainerView.leadingAnchor, constant: 1)
    let imageViewCenterXAnchorConstraint = imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor)
    let imageViewTrailingAnchorConstraint = imageView
      .trailingAnchor
      .constraint(equalTo: imageContainerView.trailingAnchor, constant: -1)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      widthAnchorConstraint,
      imageContainerViewTopAnchorConstraint,
      imageContainerViewLeadingAnchorConstraint,
      imageContainerViewTrailingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      descriptionViewTopAnchorConstraint,
      descriptionViewLeadingAnchorConstraint,
      descriptionViewTrailingAnchorConstraint,
      imageContainerViewHeightAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewBottomAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewCenterXAnchorConstraint,
      imageViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    fillColor = Colors.transparent
    borderColor = Colors.transparent
    imageContainerView.borderColor = Colors.dividerSubtle
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    descriptionView.attributedStringValue = descriptionViewTextStyle.apply(to: descriptionText)
    imageView.image = image
    onPress = handleOnPressCard
    if isSelected {
      fillColor = Colors.systemSelection10
      imageContainerView.borderColor = Colors.systemSelection30
      borderColor = Colors.systemSelection
    }
  }

  private func handleOnPressCard() {
    onPressCard?()
  }

  private func updateHoverState(with event: NSEvent) {
    let hovered = bounds.contains(convert(event.locationInWindow, from: nil))
    if hovered != self.hovered {
      self.hovered = hovered

      update()
    }
  }

  public override func mouseEntered(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseMoved(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseDragged(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseExited(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseDown(with event: NSEvent) {
    let pressed = bounds.contains(convert(event.locationInWindow, from: nil))
    if pressed != self.pressed {
      self.pressed = pressed

      update()
    }
  }

  public override func mouseUp(with event: NSEvent) {
    let clicked = pressed && bounds.contains(convert(event.locationInWindow, from: nil))

    if pressed {
      pressed = false

      update()
    }

    if clicked {
      onPress?()
    }
  }
}

// MARK: - Parameters

extension WorkspaceTemplateCard {
  public struct Parameters: Equatable {
    public var titleText: String
    public var descriptionText: String
    public var isSelected: Bool
    public var image: NSImage
    public var onPressCard: (() -> Void)?

    public init(
      titleText: String,
      descriptionText: String,
      isSelected: Bool,
      image: NSImage,
      onPressCard: (() -> Void)? = nil)
    {
      self.titleText = titleText
      self.descriptionText = descriptionText
      self.isSelected = isSelected
      self.image = image
      self.onPressCard = onPressCard
    }

    public init() {
      self.init(titleText: "", descriptionText: "", isSelected: false, image: NSImage())
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText &&
        lhs.descriptionText == rhs.descriptionText && lhs.isSelected == rhs.isSelected && lhs.image == rhs.image
    }
  }
}

// MARK: - Model

extension WorkspaceTemplateCard {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "WorkspaceTemplateCard"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      titleText: String,
      descriptionText: String,
      isSelected: Bool,
      image: NSImage,
      onPressCard: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            titleText: titleText,
            descriptionText: descriptionText,
            isSelected: isSelected,
            image: image,
            onPressCard: onPressCard))
    }

    public init() {
      self.init(titleText: "", descriptionText: "", isSelected: false, image: NSImage())
    }
  }
}
