import AppKit
import Foundation

// MARK: - OpenProjectButton

public class OpenProjectButton: NSBox {

  // MARK: Lifecycle

  public init(titleText: String) {
    self.titleText = titleText

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(titleText: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var titleText: String { didSet { update() } }
  public var onPressTitle: (() -> Void)? { didSet { update() } }
  public var onPressPlus: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var topBorderView = NSBox()
  private var innerView = NSBox()
  private var titleContainerView = NSBox()
  private var titleView = NSTextField(labelWithString: "")
  private var plusContainerView = NSBox()
  private var plusView = NSImageView()

  private var titleViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var topBorderViewTopMargin: CGFloat = 0
  private var topBorderViewTrailingMargin: CGFloat = 0
  private var topBorderViewBottomMargin: CGFloat = 0
  private var topBorderViewLeadingMargin: CGFloat = 0
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 20
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 20
  private var titleContainerViewTopMargin: CGFloat = 0
  private var titleContainerViewTrailingMargin: CGFloat = 20
  private var titleContainerViewBottomMargin: CGFloat = 0
  private var titleContainerViewLeadingMargin: CGFloat = 0
  private var titleContainerViewTopPadding: CGFloat = 0
  private var titleContainerViewTrailingPadding: CGFloat = 0
  private var titleContainerViewBottomPadding: CGFloat = 0
  private var titleContainerViewLeadingPadding: CGFloat = 0
  private var plusContainerViewTopMargin: CGFloat = 0
  private var plusContainerViewTrailingMargin: CGFloat = 0
  private var plusContainerViewBottomMargin: CGFloat = 0
  private var plusContainerViewLeadingMargin: CGFloat = 0
  private var plusContainerViewTopPadding: CGFloat = 0
  private var plusContainerViewTrailingPadding: CGFloat = 0
  private var plusContainerViewBottomPadding: CGFloat = 0
  private var plusContainerViewLeadingPadding: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var plusViewTopMargin: CGFloat = 0
  private var plusViewTrailingMargin: CGFloat = 0
  private var plusViewBottomMargin: CGFloat = 0
  private var plusViewLeadingMargin: CGFloat = 0

  private var titleContainerViewHovered = false
  private var titleContainerViewPressed = false
  private var titleContainerViewOnPress: (() -> Void)?
  private var plusContainerViewHovered = false
  private var plusContainerViewPressed = false
  private var plusContainerViewOnPress: (() -> Void)?

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var topBorderViewTopAnchorConstraint: NSLayoutConstraint?
  private var topBorderViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var topBorderViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var topBorderViewHeightAnchorConstraint: NSLayoutConstraint?
  private var titleContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleContainerViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var titleContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var plusContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var plusContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var plusContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var plusContainerViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var plusContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var plusViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var plusViewTopAnchorConstraint: NSLayoutConstraint?
  private var plusViewBottomAnchorConstraint: NSLayoutConstraint?
  private var plusViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var plusViewHeightAnchorConstraint: NSLayoutConstraint?
  private var plusViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    topBorderView.boxType = .custom
    topBorderView.borderType = .noBorder
    topBorderView.contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    titleContainerView.boxType = .custom
    titleContainerView.borderType = .noBorder
    titleContainerView.contentViewMargins = .zero
    plusContainerView.boxType = .custom
    plusContainerView.borderType = .noBorder
    plusContainerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping

    addSubview(topBorderView)
    addSubview(innerView)
    innerView.addSubview(titleContainerView)
    innerView.addSubview(plusContainerView)
    titleContainerView.addSubview(titleView)
    plusContainerView.addSubview(plusView)

    topBorderView.fillColor = Colors.grey200
    plusView.image = #imageLiteral(resourceName: "icon-plus")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    topBorderView.translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    plusContainerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    plusView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 48)
    let topBorderViewTopAnchorConstraint = topBorderView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + topBorderViewTopMargin)
    let topBorderViewLeadingAnchorConstraint = topBorderView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + topBorderViewLeadingMargin)
    let topBorderViewTrailingAnchorConstraint = topBorderView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + topBorderViewTrailingMargin))
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + innerViewBottomMargin))
    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topBorderView.bottomAnchor, constant: topBorderViewBottomMargin + innerViewTopMargin)
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + innerViewLeadingMargin)
    let innerViewTrailingAnchorConstraint = innerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + innerViewTrailingMargin))
    let topBorderViewHeightAnchorConstraint = topBorderView.heightAnchor.constraint(equalToConstant: 1)
    let titleContainerViewLeadingAnchorConstraint = titleContainerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + titleContainerViewLeadingMargin)
    let titleContainerViewTopAnchorConstraint = titleContainerView
      .topAnchor
      .constraint(
        greaterThanOrEqualTo: innerView.topAnchor,
        constant: innerViewTopPadding + titleContainerViewTopMargin)
    let titleContainerViewCenterYAnchorConstraint = titleContainerView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor, constant: 0)
    let titleContainerViewBottomAnchorConstraint = titleContainerView
      .bottomAnchor
      .constraint(
        lessThanOrEqualTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + titleContainerViewBottomMargin))
    let plusContainerViewTrailingAnchorConstraint = plusContainerView
      .trailingAnchor
      .constraint(
        equalTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + plusContainerViewTrailingMargin))
    let plusContainerViewLeadingAnchorConstraint = plusContainerView
      .leadingAnchor
      .constraint(
        equalTo: titleContainerView.trailingAnchor,
        constant: titleContainerViewTrailingMargin + plusContainerViewLeadingMargin)
    let plusContainerViewTopAnchorConstraint = plusContainerView
      .topAnchor
      .constraint(greaterThanOrEqualTo: innerView.topAnchor, constant: innerViewTopPadding + plusContainerViewTopMargin)
    let plusContainerViewCenterYAnchorConstraint = plusContainerView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor, constant: 0)
    let plusContainerViewBottomAnchorConstraint = plusContainerView
      .bottomAnchor
      .constraint(
        lessThanOrEqualTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + plusContainerViewBottomMargin))
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: titleContainerView.topAnchor, constant: titleContainerViewTopPadding + titleViewTopMargin)
    let titleViewBottomAnchorConstraint = titleView
      .bottomAnchor
      .constraint(
        equalTo: titleContainerView.bottomAnchor,
        constant: -(titleContainerViewBottomPadding + titleViewBottomMargin))
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(
        equalTo: titleContainerView.leadingAnchor,
        constant: titleContainerViewLeadingPadding + titleViewLeadingMargin)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: titleContainerView.trailingAnchor,
        constant: -(titleContainerViewTrailingPadding + titleViewTrailingMargin))
    let plusViewWidthAnchorParentConstraint = plusView
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: plusContainerView.widthAnchor,
        constant:
        -(
        plusContainerViewLeadingPadding + plusViewLeadingMargin +
          plusContainerViewTrailingPadding + plusViewTrailingMargin
        ))
    let plusViewTopAnchorConstraint = plusView
      .topAnchor
      .constraint(equalTo: plusContainerView.topAnchor, constant: plusContainerViewTopPadding + plusViewTopMargin)
    let plusViewBottomAnchorConstraint = plusView
      .bottomAnchor
      .constraint(
        equalTo: plusContainerView.bottomAnchor,
        constant: -(plusContainerViewBottomPadding + plusViewBottomMargin))
    let plusViewLeadingAnchorConstraint = plusView
      .leadingAnchor
      .constraint(
        equalTo: plusContainerView.leadingAnchor,
        constant: plusContainerViewLeadingPadding + plusViewLeadingMargin)
    let plusViewHeightAnchorConstraint = plusView.heightAnchor.constraint(equalToConstant: 20)
    let plusViewWidthAnchorConstraint = plusView.widthAnchor.constraint(equalToConstant: 20)
    plusViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      topBorderViewTopAnchorConstraint,
      topBorderViewLeadingAnchorConstraint,
      topBorderViewTrailingAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      topBorderViewHeightAnchorConstraint,
      titleContainerViewLeadingAnchorConstraint,
      titleContainerViewTopAnchorConstraint,
      titleContainerViewCenterYAnchorConstraint,
      titleContainerViewBottomAnchorConstraint,
      plusContainerViewTrailingAnchorConstraint,
      plusContainerViewLeadingAnchorConstraint,
      plusContainerViewTopAnchorConstraint,
      plusContainerViewCenterYAnchorConstraint,
      plusContainerViewBottomAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewBottomAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      plusViewWidthAnchorParentConstraint,
      plusViewTopAnchorConstraint,
      plusViewBottomAnchorConstraint,
      plusViewLeadingAnchorConstraint,
      plusViewHeightAnchorConstraint,
      plusViewWidthAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.topBorderViewTopAnchorConstraint = topBorderViewTopAnchorConstraint
    self.topBorderViewLeadingAnchorConstraint = topBorderViewLeadingAnchorConstraint
    self.topBorderViewTrailingAnchorConstraint = topBorderViewTrailingAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewTrailingAnchorConstraint = innerViewTrailingAnchorConstraint
    self.topBorderViewHeightAnchorConstraint = topBorderViewHeightAnchorConstraint
    self.titleContainerViewLeadingAnchorConstraint = titleContainerViewLeadingAnchorConstraint
    self.titleContainerViewTopAnchorConstraint = titleContainerViewTopAnchorConstraint
    self.titleContainerViewCenterYAnchorConstraint = titleContainerViewCenterYAnchorConstraint
    self.titleContainerViewBottomAnchorConstraint = titleContainerViewBottomAnchorConstraint
    self.plusContainerViewTrailingAnchorConstraint = plusContainerViewTrailingAnchorConstraint
    self.plusContainerViewLeadingAnchorConstraint = plusContainerViewLeadingAnchorConstraint
    self.plusContainerViewTopAnchorConstraint = plusContainerViewTopAnchorConstraint
    self.plusContainerViewCenterYAnchorConstraint = plusContainerViewCenterYAnchorConstraint
    self.plusContainerViewBottomAnchorConstraint = plusContainerViewBottomAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewBottomAnchorConstraint = titleViewBottomAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.plusViewWidthAnchorParentConstraint = plusViewWidthAnchorParentConstraint
    self.plusViewTopAnchorConstraint = plusViewTopAnchorConstraint
    self.plusViewBottomAnchorConstraint = plusViewBottomAnchorConstraint
    self.plusViewLeadingAnchorConstraint = plusViewLeadingAnchorConstraint
    self.plusViewHeightAnchorConstraint = plusViewHeightAnchorConstraint
    self.plusViewWidthAnchorConstraint = plusViewWidthAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    topBorderViewTopAnchorConstraint.identifier = "topBorderViewTopAnchorConstraint"
    topBorderViewLeadingAnchorConstraint.identifier = "topBorderViewLeadingAnchorConstraint"
    topBorderViewTrailingAnchorConstraint.identifier = "topBorderViewTrailingAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewTrailingAnchorConstraint.identifier = "innerViewTrailingAnchorConstraint"
    topBorderViewHeightAnchorConstraint.identifier = "topBorderViewHeightAnchorConstraint"
    titleContainerViewLeadingAnchorConstraint.identifier = "titleContainerViewLeadingAnchorConstraint"
    titleContainerViewTopAnchorConstraint.identifier = "titleContainerViewTopAnchorConstraint"
    titleContainerViewCenterYAnchorConstraint.identifier = "titleContainerViewCenterYAnchorConstraint"
    titleContainerViewBottomAnchorConstraint.identifier = "titleContainerViewBottomAnchorConstraint"
    plusContainerViewTrailingAnchorConstraint.identifier = "plusContainerViewTrailingAnchorConstraint"
    plusContainerViewLeadingAnchorConstraint.identifier = "plusContainerViewLeadingAnchorConstraint"
    plusContainerViewTopAnchorConstraint.identifier = "plusContainerViewTopAnchorConstraint"
    plusContainerViewCenterYAnchorConstraint.identifier = "plusContainerViewCenterYAnchorConstraint"
    plusContainerViewBottomAnchorConstraint.identifier = "plusContainerViewBottomAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewBottomAnchorConstraint.identifier = "titleViewBottomAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    plusViewWidthAnchorParentConstraint.identifier = "plusViewWidthAnchorParentConstraint"
    plusViewTopAnchorConstraint.identifier = "plusViewTopAnchorConstraint"
    plusViewBottomAnchorConstraint.identifier = "plusViewBottomAnchorConstraint"
    plusViewLeadingAnchorConstraint.identifier = "plusViewLeadingAnchorConstraint"
    plusViewHeightAnchorConstraint.identifier = "plusViewHeightAnchorConstraint"
    plusViewWidthAnchorConstraint.identifier = "plusViewWidthAnchorConstraint"
  }

  private func update() {
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    titleContainerViewOnPress = onPressTitle
    plusContainerViewOnPress = onPressPlus
  }

  private func updateHoverState(with event: NSEvent) {
    let titleContainerViewHovered = titleContainerView
      .bounds
      .contains(titleContainerView.convert(event.locationInWindow, from: nil))
    let plusContainerViewHovered = plusContainerView
      .bounds
      .contains(plusContainerView.convert(event.locationInWindow, from: nil))
    if
    titleContainerViewHovered != self.titleContainerViewHovered ||
      plusContainerViewHovered != self.plusContainerViewHovered
    {
      self.titleContainerViewHovered = titleContainerViewHovered
      self.plusContainerViewHovered = plusContainerViewHovered

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
    let titleContainerViewPressed = titleContainerView
      .bounds
      .contains(titleContainerView.convert(event.locationInWindow, from: nil))
    let plusContainerViewPressed = plusContainerView
      .bounds
      .contains(plusContainerView.convert(event.locationInWindow, from: nil))
    if
    titleContainerViewPressed != self.titleContainerViewPressed ||
      plusContainerViewPressed != self.plusContainerViewPressed
    {
      self.titleContainerViewPressed = titleContainerViewPressed
      self.plusContainerViewPressed = plusContainerViewPressed

      update()
    }
  }

  public override func mouseUp(with event: NSEvent) {
    let titleContainerViewClicked = titleContainerViewPressed &&
      titleContainerView.bounds.contains(titleContainerView.convert(event.locationInWindow, from: nil))
    let plusContainerViewClicked = plusContainerViewPressed &&
      plusContainerView.bounds.contains(plusContainerView.convert(event.locationInWindow, from: nil))

    if titleContainerViewPressed || plusContainerViewPressed {
      titleContainerViewPressed = false
      plusContainerViewPressed = false

      update()
    }

    if titleContainerViewClicked {
      titleContainerViewOnPress?()
    }
    if plusContainerViewClicked {
      plusContainerViewOnPress?()
    }
  }
}
