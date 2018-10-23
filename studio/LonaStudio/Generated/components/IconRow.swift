import AppKit
import Foundation

// MARK: - IconRow

public class IconRow: NSBox {

  // MARK: Lifecycle

  public init(titleText: String, subtitleText: String, icon: NSImage) {
    self.titleText = titleText
    self.subtitleText = subtitleText
    self.icon = icon

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(titleText: "", subtitleText: "", icon: NSImage())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var titleText: String { didSet { update() } }
  public var subtitleText: String { didSet { update() } }
  public var icon: NSImage { didSet { update() } }
  public var onClick: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var imageView = NSImageView()
  private var rowContentView = NSBox()
  private var titleView = NSTextField(labelWithString: "")
  private var subtitleView = NSTextField(labelWithString: "")

  private var titleViewTextStyle = TextStyles.largeSemibold
  private var subtitleViewTextStyle = TextStyles.regularMuted

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    rowContentView.boxType = .custom
    rowContentView.borderType = .noBorder
    rowContentView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    subtitleView.lineBreakMode = .byWordWrapping

    addSubview(imageView)
    addSubview(rowContentView)
    rowContentView.addSubview(titleView)
    rowContentView.addSubview(subtitleView)

    titleViewTextStyle = TextStyles.largeSemibold
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    subtitleViewTextStyle = TextStyles.regularMuted
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    rowContentView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    subtitleView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewHeightAnchorParentConstraint = imageView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -16)
    let rowContentViewHeightAnchorParentConstraint = rowContentView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8)
    let rowContentViewTrailingAnchorConstraint = rowContentView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let rowContentViewLeadingAnchorConstraint = rowContentView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: 16)
    let rowContentViewTopAnchorConstraint = rowContentView.topAnchor.constraint(equalTo: topAnchor)
    let rowContentViewBottomAnchorConstraint = rowContentView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 30)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 30)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: rowContentView.topAnchor, constant: 8)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: rowContentView.leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: rowContentView.trailingAnchor)
    let subtitleViewBottomAnchorConstraint = subtitleView
      .bottomAnchor
      .constraint(equalTo: rowContentView.bottomAnchor, constant: -8)
    let subtitleViewTopAnchorConstraint = subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let subtitleViewLeadingAnchorConstraint = subtitleView
      .leadingAnchor
      .constraint(equalTo: rowContentView.leadingAnchor)
    let subtitleViewTrailingAnchorConstraint = subtitleView
      .trailingAnchor
      .constraint(equalTo: rowContentView.trailingAnchor)

    imageViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    rowContentViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      imageViewHeightAnchorParentConstraint,
      rowContentViewHeightAnchorParentConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewTopAnchorConstraint,
      rowContentViewTrailingAnchorConstraint,
      rowContentViewLeadingAnchorConstraint,
      rowContentViewTopAnchorConstraint,
      rowContentViewBottomAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      subtitleViewBottomAnchorConstraint,
      subtitleViewTopAnchorConstraint,
      subtitleViewLeadingAnchorConstraint,
      subtitleViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    fillColor = Colors.transparent
    onPress = onClick
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleText)
    imageView.image = icon
    if pressed {
      fillColor = Colors.pink50
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
