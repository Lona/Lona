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
  private var dividerView = NSBox()
  private var plusContainerView = NSBox()
  private var plusView = NSImageView()

  private var titleViewTextStyle = TextStyles.regular

  private var titleContainerViewHovered = false
  private var titleContainerViewPressed = false
  private var titleContainerViewOnPress: (() -> Void)?
  private var plusContainerViewHovered = false
  private var plusContainerViewPressed = false
  private var plusContainerViewOnPress: (() -> Void)?

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
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    plusContainerView.boxType = .custom
    plusContainerView.borderType = .noBorder
    plusContainerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping

    addSubview(topBorderView)
    addSubview(innerView)
    innerView.addSubview(titleContainerView)
    innerView.addSubview(dividerView)
    innerView.addSubview(plusContainerView)
    titleContainerView.addSubview(titleView)
    plusContainerView.addSubview(plusView)

    topBorderView.fillColor = Colors.grey200
    dividerView.fillColor = Colors.grey200
    plusView.image = #imageLiteral(resourceName: "icon-plus")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    topBorderView.translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    plusContainerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    plusView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 48)
    let topBorderViewTopAnchorConstraint = topBorderView.topAnchor.constraint(equalTo: topAnchor)
    let topBorderViewLeadingAnchorConstraint = topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let topBorderViewTrailingAnchorConstraint = topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topBorderView.bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let topBorderViewHeightAnchorConstraint = topBorderView.heightAnchor.constraint(equalToConstant: 1)
    let titleContainerViewLeadingAnchorConstraint = titleContainerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 12)
    let titleContainerViewTopAnchorConstraint = titleContainerView
      .topAnchor
      .constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let titleContainerViewCenterYAnchorConstraint = titleContainerView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor)
    let titleContainerViewBottomAnchorConstraint = titleContainerView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: titleContainerView.trailingAnchor, constant: 20)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let dividerViewCenterYAnchorConstraint = dividerView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let dividerViewBottomAnchorConstraint = dividerView.bottomAnchor.constraint(equalTo: innerView.bottomAnchor)
    let plusContainerViewTrailingAnchorConstraint = plusContainerView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -16)
    let plusContainerViewLeadingAnchorConstraint = plusContainerView
      .leadingAnchor
      .constraint(equalTo: dividerView.trailingAnchor, constant: 16)
    let plusContainerViewTopAnchorConstraint = plusContainerView
      .topAnchor
      .constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let plusContainerViewCenterYAnchorConstraint = plusContainerView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor)
    let plusContainerViewBottomAnchorConstraint = plusContainerView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: titleContainerView.topAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.trailingAnchor)
    let dividerViewWidthAnchorConstraint = dividerView.widthAnchor.constraint(equalToConstant: 1)
    let plusViewWidthAnchorParentConstraint = plusView
      .widthAnchor
      .constraint(lessThanOrEqualTo: plusContainerView.widthAnchor)
    let plusViewTopAnchorConstraint = plusView.topAnchor.constraint(equalTo: plusContainerView.topAnchor)
    let plusViewBottomAnchorConstraint = plusView.bottomAnchor.constraint(equalTo: plusContainerView.bottomAnchor)
    let plusViewLeadingAnchorConstraint = plusView.leadingAnchor.constraint(equalTo: plusContainerView.leadingAnchor)
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
      dividerViewLeadingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewCenterYAnchorConstraint,
      dividerViewBottomAnchorConstraint,
      plusContainerViewTrailingAnchorConstraint,
      plusContainerViewLeadingAnchorConstraint,
      plusContainerViewTopAnchorConstraint,
      plusContainerViewCenterYAnchorConstraint,
      plusContainerViewBottomAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewBottomAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      dividerViewWidthAnchorConstraint,
      plusViewWidthAnchorParentConstraint,
      plusViewTopAnchorConstraint,
      plusViewBottomAnchorConstraint,
      plusViewLeadingAnchorConstraint,
      plusViewHeightAnchorConstraint,
      plusViewWidthAnchorConstraint
    ])
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
