import AppKit
import Foundation

// MARK: - Button

public class Button: NSBox {

  // MARK: Lifecycle

  public init(label: String) {
    self.label = label

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(label: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var label: String { didSet { update() } }
  public var onTap: (() -> Void)?

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var textView = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.subheading2

  private var topPadding: CGFloat = 12
  private var trailingPadding: CGFloat = 16
  private var bottomPadding: CGFloat = 12
  private var leadingPadding: CGFloat = 16
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private var textViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping

    addSubview(textView)

    textViewTextStyle = TextStyles.subheading2
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let textViewWidthAnchorParentConstraint = textView
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: widthAnchor,
        constant: -(leadingPadding + textViewLeadingMargin + trailingPadding + textViewTrailingMargin))
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + textViewTopMargin)
    let textViewBottomAnchorConstraint = textView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + textViewBottomMargin))
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))
    textViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])

    self.textViewWidthAnchorParentConstraint = textViewWidthAnchorParentConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint

    // For debugging
    textViewWidthAnchorParentConstraint.identifier = "textViewWidthAnchorParentConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewBottomAnchorConstraint.identifier = "textViewBottomAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
  }

  private func update() {
    fillColor = Colors.blue100
    textView.attributedStringValue = textViewTextStyle.apply(to: label)
    onPress = onTap
    if hovered {
      fillColor = Colors.blue200
    }
    if pressed {
      fillColor = Colors.blue50
    }
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