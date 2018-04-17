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
  public var onClick: (() -> Void)?

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

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 8
  private var imageViewTrailingMargin: CGFloat = 16
  private var imageViewBottomMargin: CGFloat = 8
  private var imageViewLeadingMargin: CGFloat = 8
  private var rowContentViewTopMargin: CGFloat = 0
  private var rowContentViewTrailingMargin: CGFloat = 0
  private var rowContentViewBottomMargin: CGFloat = 0
  private var rowContentViewLeadingMargin: CGFloat = 0
  private var rowContentViewTopPadding: CGFloat = 8
  private var rowContentViewTrailingPadding: CGFloat = 0
  private var rowContentViewBottomPadding: CGFloat = 8
  private var rowContentViewLeadingPadding: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var subtitleViewTopMargin: CGFloat = 0
  private var subtitleViewTrailingMargin: CGFloat = 0
  private var subtitleViewBottomMargin: CGFloat = 0
  private var subtitleViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private var imageViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var rowContentViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var rowContentViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var rowContentViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var rowContentViewTopAnchorConstraint: NSLayoutConstraint?
  private var rowContentViewBottomAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewTopAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    subtitleViewTextStyle = TextStyles.regularMuted
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    rowContentView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    subtitleView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewHeightAnchorParentConstraint = imageView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: heightAnchor,
        constant: -(topPadding + imageViewTopMargin + bottomPadding + imageViewBottomMargin))
    let rowContentViewHeightAnchorParentConstraint = rowContentView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: heightAnchor,
        constant: -(topPadding + rowContentViewTopMargin + bottomPadding + rowContentViewBottomMargin))
    let imageViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + imageViewLeadingMargin)
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + imageViewTopMargin)
    let rowContentViewTrailingAnchorConstraint = rowContentView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + rowContentViewTrailingMargin))
    let rowContentViewLeadingAnchorConstraint = rowContentView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: imageViewTrailingMargin + rowContentViewLeadingMargin)
    let rowContentViewTopAnchorConstraint = rowContentView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + rowContentViewTopMargin)
    let rowContentViewBottomAnchorConstraint = rowContentView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + rowContentViewBottomMargin))
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 30)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 30)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: rowContentView.topAnchor, constant: rowContentViewTopPadding + titleViewTopMargin)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(
        equalTo: rowContentView.leadingAnchor,
        constant: rowContentViewLeadingPadding + titleViewLeadingMargin)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(
        equalTo: rowContentView.trailingAnchor,
        constant: -(rowContentViewTrailingPadding + titleViewTrailingMargin))
    let subtitleViewBottomAnchorConstraint = subtitleView
      .bottomAnchor
      .constraint(
        equalTo: rowContentView.bottomAnchor,
        constant: -(rowContentViewBottomPadding + subtitleViewBottomMargin))
    let subtitleViewTopAnchorConstraint = subtitleView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: titleViewBottomMargin + subtitleViewTopMargin)
    let subtitleViewLeadingAnchorConstraint = subtitleView
      .leadingAnchor
      .constraint(
        equalTo: rowContentView.leadingAnchor,
        constant: rowContentViewLeadingPadding + subtitleViewLeadingMargin)
    let subtitleViewTrailingAnchorConstraint = subtitleView
      .trailingAnchor
      .constraint(
        equalTo: rowContentView.trailingAnchor,
        constant: -(rowContentViewTrailingPadding + subtitleViewTrailingMargin))
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

    self.imageViewHeightAnchorParentConstraint = imageViewHeightAnchorParentConstraint
    self.rowContentViewHeightAnchorParentConstraint = rowContentViewHeightAnchorParentConstraint
    self.imageViewLeadingAnchorConstraint = imageViewLeadingAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.rowContentViewTrailingAnchorConstraint = rowContentViewTrailingAnchorConstraint
    self.rowContentViewLeadingAnchorConstraint = rowContentViewLeadingAnchorConstraint
    self.rowContentViewTopAnchorConstraint = rowContentViewTopAnchorConstraint
    self.rowContentViewBottomAnchorConstraint = rowContentViewBottomAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.subtitleViewBottomAnchorConstraint = subtitleViewBottomAnchorConstraint
    self.subtitleViewTopAnchorConstraint = subtitleViewTopAnchorConstraint
    self.subtitleViewLeadingAnchorConstraint = subtitleViewLeadingAnchorConstraint
    self.subtitleViewTrailingAnchorConstraint = subtitleViewTrailingAnchorConstraint

    // For debugging
    imageViewHeightAnchorParentConstraint.identifier = "imageViewHeightAnchorParentConstraint"
    rowContentViewHeightAnchorParentConstraint.identifier = "rowContentViewHeightAnchorParentConstraint"
    imageViewLeadingAnchorConstraint.identifier = "imageViewLeadingAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    rowContentViewTrailingAnchorConstraint.identifier = "rowContentViewTrailingAnchorConstraint"
    rowContentViewLeadingAnchorConstraint.identifier = "rowContentViewLeadingAnchorConstraint"
    rowContentViewTopAnchorConstraint.identifier = "rowContentViewTopAnchorConstraint"
    rowContentViewBottomAnchorConstraint.identifier = "rowContentViewBottomAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    subtitleViewBottomAnchorConstraint.identifier = "subtitleViewBottomAnchorConstraint"
    subtitleViewTopAnchorConstraint.identifier = "subtitleViewTopAnchorConstraint"
    subtitleViewLeadingAnchorConstraint.identifier = "subtitleViewLeadingAnchorConstraint"
    subtitleViewTrailingAnchorConstraint.identifier = "subtitleViewTrailingAnchorConstraint"
  }

  private func update() {
    fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    onPress = onClick
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleText)
    imageView.image = icon
    if hovered {
      fillColor = Colors.red50
    }
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