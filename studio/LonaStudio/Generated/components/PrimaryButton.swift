import AppKit
import Foundation

// MARK: - PrimaryButton

public class PrimaryButton: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init(titleText: String, disabled: Bool) {
    self.init(Parameters(titleText: titleText, disabled: disabled))
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

  public var onClick: (() -> Void)? {
    get { return parameters.onClick }
    set { parameters.onClick = newValue }
  }

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var disabled: Bool {
    get { return parameters.disabled }
    set {
      if parameters.disabled != newValue {
        parameters.disabled = newValue
      }
    }
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

  private var titleView = LNATextField(labelWithString: "")

  private var titleViewTextStyle = TextStyles.regular.with(alignment: .center)

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping

    addSubview(titleView)

    cornerRadius = 2
    borderWidth = 1
    titleView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 9)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9)

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewBottomAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    fillColor = Colors.controlBackground
    borderColor = Colors.divider
    titleViewTextStyle = TextStyles.regular.with(alignment: .center)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    onPress = handleOnClick
    if disabled == false {
      if hovered {
        fillColor = Colors.darkTransparentOutline
      }
    }
    if disabled {
      titleViewTextStyle = TextStyles.regularMuted.with(alignment: .center)
      titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
      borderColor = Colors.dividerSubtle
      fillColor = Colors.transparent
    }
  }

  private func handleOnClick() {
    onClick?()
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

extension PrimaryButton {
  public struct Parameters: Equatable {
    public var titleText: String
    public var disabled: Bool
    public var onClick: (() -> Void)?

    public init(titleText: String, disabled: Bool, onClick: (() -> Void)? = nil) {
      self.titleText = titleText
      self.disabled = disabled
      self.onClick = onClick
    }

    public init() {
      self.init(titleText: "", disabled: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText && lhs.disabled == rhs.disabled
    }
  }
}

// MARK: - Model

extension PrimaryButton {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PrimaryButton"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(titleText: String, disabled: Bool, onClick: (() -> Void)? = nil) {
      self.init(Parameters(titleText: titleText, disabled: disabled, onClick: onClick))
    }

    public init() {
      self.init(titleText: "", disabled: false)
    }
  }
}

// LONA: KEEP BELOW

extension PrimaryButton {
  public override func updateConstraints() {
    self.titleView.setContentCompressionResistancePriority(.required, for: .vertical)
    super.updateConstraints()
  }
}
