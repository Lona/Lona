import AppKit
import Foundation

// MARK: - CanvasTableHeaderItem

public class CanvasTableHeaderItem: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init(titleText: String, dividerColor: NSColor, selected: Bool) {
    self.init(Parameters(titleText: titleText, dividerColor: dividerColor, selected: selected))
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

  public var dividerColor: NSColor {
    get { return parameters.dividerColor }
    set {
      if parameters.dividerColor != newValue {
        parameters.dividerColor = newValue
      }
    }
  }

  public var onClick: (() -> Void)? {
    get { return parameters.onClick }
    set { parameters.onClick = newValue }
  }

  public var selected: Bool {
    get { return parameters.selected }
    set {
      if parameters.selected != newValue {
        parameters.selected = newValue
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

  private var innerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var vDividerView = NSBox()
  private var hDividerView = NSBox()

  private var titleViewTextStyle = TextStyles.sectionTitle.with(alignment: .center)

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    hDividerView.boxType = .custom
    hDividerView.borderType = .noBorder
    hDividerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vDividerView.boxType = .custom
    vDividerView.borderType = .noBorder
    vDividerView.contentViewMargins = .zero

    addSubview(innerView)
    addSubview(hDividerView)
    innerView.addSubview(titleView)
    innerView.addSubview(vDividerView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    hDividerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    vDividerView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 38)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let hDividerViewBottomAnchorConstraint = hDividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let hDividerViewTopAnchorConstraint = hDividerView.topAnchor.constraint(equalTo: innerView.bottomAnchor)
    let hDividerViewLeadingAnchorConstraint = hDividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let hDividerViewCenterXAnchorConstraint = hDividerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let hDividerViewTrailingAnchorConstraint = hDividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let vDividerViewTrailingAnchorConstraint = vDividerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let vDividerViewLeadingAnchorConstraint = vDividerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let vDividerViewTopAnchorConstraint = vDividerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let vDividerViewCenterYAnchorConstraint = vDividerView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let vDividerViewBottomAnchorConstraint = vDividerView.bottomAnchor.constraint(equalTo: innerView.bottomAnchor)
    let hDividerViewHeightAnchorConstraint = hDividerView.heightAnchor.constraint(equalToConstant: 1)
    let vDividerViewWidthAnchorConstraint = vDividerView.widthAnchor.constraint(equalToConstant: 1)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      hDividerViewBottomAnchorConstraint,
      hDividerViewTopAnchorConstraint,
      hDividerViewLeadingAnchorConstraint,
      hDividerViewCenterXAnchorConstraint,
      hDividerViewTrailingAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      vDividerViewTrailingAnchorConstraint,
      vDividerViewLeadingAnchorConstraint,
      vDividerViewTopAnchorConstraint,
      vDividerViewCenterYAnchorConstraint,
      vDividerViewBottomAnchorConstraint,
      hDividerViewHeightAnchorConstraint,
      vDividerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    fillColor = Colors.white
    titleViewTextStyle = TextStyles.sectionTitle.with(alignment: .center)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    hDividerView.fillColor = dividerColor
    vDividerView.fillColor = dividerColor
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    onPress = handleOnClick
    if pressed {
      fillColor = Colors.headerBackground
    }
    if selected {
      fillColor = Colors.blue600
      titleViewTextStyle = TextStyles.sectionTitleInverse.with(alignment: .center)
      titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
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

extension CanvasTableHeaderItem {
  public struct Parameters: Equatable {
    public var titleText: String
    public var dividerColor: NSColor
    public var selected: Bool
    public var onClick: (() -> Void)?

    public init(titleText: String, dividerColor: NSColor, selected: Bool, onClick: (() -> Void)? = nil) {
      self.titleText = titleText
      self.dividerColor = dividerColor
      self.selected = selected
      self.onClick = onClick
    }

    public init() {
      self.init(titleText: "", dividerColor: NSColor.clear, selected: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText && lhs.dividerColor == rhs.dividerColor && lhs.selected == rhs.selected
    }
  }
}

// MARK: - Model

extension CanvasTableHeaderItem {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "CanvasTableHeaderItem"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(titleText: String, dividerColor: NSColor, selected: Bool, onClick: (() -> Void)? = nil) {
      self.init(Parameters(titleText: titleText, dividerColor: dividerColor, selected: selected, onClick: onClick))
    }

    public init() {
      self.init(titleText: "", dividerColor: NSColor.clear, selected: false)
    }
  }
}
