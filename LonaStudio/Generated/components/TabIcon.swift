import AppKit
import Foundation

// MARK: - TabIcon

public class TabIcon: NSBox {

  // MARK: Lifecycle

  public init(icon: NSImage, selected: Bool) {
    self.icon = icon
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(icon: NSImage(), selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var icon: NSImage { didSet { update() } }
  public var onClick: (() -> Void)? { didSet { update() } }
  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var imageView = NSImageView()

  private var topPadding: CGFloat = 17
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 17
  private var leadingPadding: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 0
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var widthAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(imageView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 60)
    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: 60)
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + imageViewTopMargin)
    let imageViewCenterXAnchorConstraint = imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 26)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 26)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      widthAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewCenterXAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.widthAnchorConstraint = widthAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewCenterXAnchorConstraint = imageViewCenterXAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    widthAnchorConstraint.identifier = "widthAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewCenterXAnchorConstraint.identifier = "imageViewCenterXAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
  }

  private func update() {
    fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    imageView.image = icon
    onPress = onClick
    if selected {
      fillColor = Colors.grey300
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
