import AppKit
import Foundation

// MARK: - AccessibilityTest

public class AccessibilityTest: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init(customTextAccessibilityLabel: String, checkboxValue: Bool) {
    self.init(Parameters(customTextAccessibilityLabel: customTextAccessibilityLabel, checkboxValue: checkboxValue))
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

  public var customTextAccessibilityLabel: String {
    get { return parameters.customTextAccessibilityLabel }
    set {
      if parameters.customTextAccessibilityLabel != newValue {
        parameters.customTextAccessibilityLabel = newValue
      }
    }
  }

  public var checkboxValue: Bool {
    get { return parameters.checkboxValue }
    set {
      if parameters.checkboxValue != newValue {
        parameters.checkboxValue = newValue
      }
    }
  }

  public var onToggleCheckbox: (() -> Void)? {
    get { return parameters.onToggleCheckbox }
    set { parameters.onToggleCheckbox = newValue }
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

  private var checkboxRowView = NSBox()
  private var checkboxView = NSBox()
  private var checkboxCircleView = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var row1View = NSBox()
  private var elementView = NSBox()
  private var innerView = NSBox()
  private var containerView = NSBox()
  private var imageView = LNAImageView()
  private var accessibleTextView = LNATextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.body1
  private var accessibleTextViewTextStyle = TextStyles.body1

  private var checkboxRowViewHovered = false
  private var checkboxRowViewPressed = false
  private var checkboxRowViewOnPress: (() -> Void)?
  private var checkboxViewHovered = false
  private var checkboxViewPressed = false
  private var checkboxViewOnPress: (() -> Void)?

  private var checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    checkboxRowView.boxType = .custom
    checkboxRowView.borderType = .noBorder
    checkboxRowView.contentViewMargins = .zero
    row1View.boxType = .custom
    row1View.borderType = .noBorder
    row1View.contentViewMargins = .zero
    checkboxView.boxType = .custom
    checkboxView.borderType = .lineBorder
    checkboxView.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    checkboxCircleView.boxType = .custom
    checkboxCircleView.borderType = .noBorder
    checkboxCircleView.contentViewMargins = .zero
    elementView.boxType = .custom
    elementView.borderType = .noBorder
    elementView.contentViewMargins = .zero
    containerView.boxType = .custom
    containerView.borderType = .noBorder
    containerView.contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    accessibleTextView.lineBreakMode = .byWordWrapping

    addSubview(checkboxRowView)
    addSubview(row1View)
    checkboxRowView.addSubview(checkboxView)
    checkboxRowView.addSubview(textView)
    checkboxView.addSubview(checkboxCircleView)
    row1View.addSubview(elementView)
    row1View.addSubview(containerView)
    elementView.addSubview(innerView)
    containerView.addSubview(imageView)
    containerView.addSubview(accessibleTextView)



    checkboxView.borderColor = Colors.grey400
    checkboxView.cornerRadius = 20
    checkboxView.borderStyle = "solid"
    checkboxView.borderWidth = 1
    checkboxCircleView.fillColor = Colors.green200
    checkboxCircleView.cornerRadius = 15
    textView.attributedStringValue = textViewTextStyle.apply(to: "Checkbox description")
    elementView.fillColor = Colors.red600




    innerView.fillColor = Colors.red800


    imageView.image = #imageLiteral(resourceName: "icon_128x128")



    accessibleTextView.attributedStringValue = accessibleTextViewTextStyle.apply(to: "Greetings")


  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    checkboxRowView.translatesAutoresizingMaskIntoConstraints = false
    row1View.translatesAutoresizingMaskIntoConstraints = false
    checkboxView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    checkboxCircleView.translatesAutoresizingMaskIntoConstraints = false
    elementView.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    accessibleTextView.translatesAutoresizingMaskIntoConstraints = false

    let checkboxRowViewTopAnchorConstraint = checkboxRowView.topAnchor.constraint(equalTo: topAnchor)
    let checkboxRowViewLeadingAnchorConstraint = checkboxRowView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let checkboxRowViewTrailingAnchorConstraint = checkboxRowView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let row1ViewBottomAnchorConstraint = row1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let row1ViewTopAnchorConstraint = row1View.topAnchor.constraint(equalTo: checkboxRowView.bottomAnchor)
    let row1ViewLeadingAnchorConstraint = row1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let row1ViewTrailingAnchorConstraint = row1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let checkboxViewHeightAnchorParentConstraint = checkboxView
      .heightAnchor
      .constraint(lessThanOrEqualTo: checkboxRowView.heightAnchor, constant: -20)
    let textViewHeightAnchorParentConstraint = textView
      .heightAnchor
      .constraint(lessThanOrEqualTo: checkboxRowView.heightAnchor, constant: -20)
    let checkboxViewLeadingAnchorConstraint = checkboxView
      .leadingAnchor
      .constraint(equalTo: checkboxRowView.leadingAnchor, constant: 10)
    let checkboxViewCenterYAnchorConstraint = checkboxView
      .centerYAnchor
      .constraint(equalTo: checkboxRowView.centerYAnchor)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: checkboxView.trailingAnchor, constant: 10)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: checkboxRowView.topAnchor, constant: 10)
    let textViewCenterYAnchorConstraint = textView.centerYAnchor.constraint(equalTo: checkboxRowView.centerYAnchor)
    let textViewBottomAnchorConstraint = textView
      .bottomAnchor
      .constraint(equalTo: checkboxRowView.bottomAnchor, constant: -10)
    let elementViewHeightAnchorParentConstraint = elementView
      .heightAnchor
      .constraint(lessThanOrEqualTo: row1View.heightAnchor, constant: -20)
    let containerViewHeightAnchorParentConstraint = containerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: row1View.heightAnchor, constant: -20)
    let elementViewLeadingAnchorConstraint = elementView
      .leadingAnchor
      .constraint(equalTo: row1View.leadingAnchor, constant: 10)
    let elementViewTopAnchorConstraint = elementView.topAnchor.constraint(equalTo: row1View.topAnchor, constant: 10)
    let containerViewTrailingAnchorConstraint = containerView
      .trailingAnchor
      .constraint(equalTo: row1View.trailingAnchor, constant: -10)
    let containerViewLeadingAnchorConstraint = containerView
      .leadingAnchor
      .constraint(equalTo: elementView.trailingAnchor, constant: 10)
    let containerViewTopAnchorConstraint = containerView.topAnchor.constraint(equalTo: row1View.topAnchor, constant: 10)
    let containerViewBottomAnchorConstraint = containerView
      .bottomAnchor
      .constraint(equalTo: row1View.bottomAnchor, constant: -10)
    let checkboxViewHeightAnchorConstraint = checkboxView.heightAnchor.constraint(equalToConstant: 30)
    let checkboxViewWidthAnchorConstraint = checkboxView.widthAnchor.constraint(equalToConstant: 30)
    let elementViewHeightAnchorConstraint = elementView.heightAnchor.constraint(equalToConstant: 50)
    let elementViewWidthAnchorConstraint = elementView.widthAnchor.constraint(equalToConstant: 50)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: elementView.topAnchor, constant: 10)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: elementView.bottomAnchor, constant: -10)
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: elementView.leadingAnchor, constant: 10)
    let innerViewTrailingAnchorConstraint = innerView
      .trailingAnchor
      .constraint(equalTo: elementView.trailingAnchor, constant: -10)
    let imageViewHeightAnchorParentConstraint = imageView
      .heightAnchor
      .constraint(lessThanOrEqualTo: containerView.heightAnchor)
    let accessibleTextViewHeightAnchorParentConstraint = accessibleTextView
      .heightAnchor
      .constraint(lessThanOrEqualTo: containerView.heightAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    let imageViewCenterYAnchorConstraint = imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
    let accessibleTextViewLeadingAnchorConstraint = accessibleTextView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: 4)
    let accessibleTextViewTopAnchorConstraint = accessibleTextView
      .topAnchor
      .constraint(equalTo: containerView.topAnchor)
    let accessibleTextViewCenterYAnchorConstraint = accessibleTextView
      .centerYAnchor
      .constraint(equalTo: containerView.centerYAnchor)
    let accessibleTextViewBottomAnchorConstraint = accessibleTextView
      .bottomAnchor
      .constraint(equalTo: containerView.bottomAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 50)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 50)
    let checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint = checkboxCircleView
      .topAnchor
      .constraint(equalTo: checkboxView.topAnchor, constant: 5)
    let checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint = checkboxCircleView
      .bottomAnchor
      .constraint(equalTo: checkboxView.bottomAnchor, constant: -5)
    let checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint = checkboxCircleView
      .leadingAnchor
      .constraint(equalTo: checkboxView.leadingAnchor, constant: 5)
    let checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint = checkboxCircleView
      .trailingAnchor
      .constraint(equalTo: checkboxView.trailingAnchor, constant: -5)

    checkboxViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    textViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    elementViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    containerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    imageViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    accessibleTextViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    self.checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint =
      checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint
    self.checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint =
      checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint
    self.checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint =
      checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint
    self.checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint =
      checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint

    NSLayoutConstraint.activate(
      [
        checkboxRowViewTopAnchorConstraint,
        checkboxRowViewLeadingAnchorConstraint,
        checkboxRowViewTrailingAnchorConstraint,
        row1ViewBottomAnchorConstraint,
        row1ViewTopAnchorConstraint,
        row1ViewLeadingAnchorConstraint,
        row1ViewTrailingAnchorConstraint,
        checkboxViewHeightAnchorParentConstraint,
        textViewHeightAnchorParentConstraint,
        checkboxViewLeadingAnchorConstraint,
        checkboxViewCenterYAnchorConstraint,
        textViewLeadingAnchorConstraint,
        textViewTopAnchorConstraint,
        textViewCenterYAnchorConstraint,
        textViewBottomAnchorConstraint,
        elementViewHeightAnchorParentConstraint,
        containerViewHeightAnchorParentConstraint,
        elementViewLeadingAnchorConstraint,
        elementViewTopAnchorConstraint,
        containerViewTrailingAnchorConstraint,
        containerViewLeadingAnchorConstraint,
        containerViewTopAnchorConstraint,
        containerViewBottomAnchorConstraint,
        checkboxViewHeightAnchorConstraint,
        checkboxViewWidthAnchorConstraint,
        elementViewHeightAnchorConstraint,
        elementViewWidthAnchorConstraint,
        innerViewTopAnchorConstraint,
        innerViewBottomAnchorConstraint,
        innerViewLeadingAnchorConstraint,
        innerViewTrailingAnchorConstraint,
        imageViewHeightAnchorParentConstraint,
        accessibleTextViewHeightAnchorParentConstraint,
        imageViewLeadingAnchorConstraint,
        imageViewCenterYAnchorConstraint,
        accessibleTextViewLeadingAnchorConstraint,
        accessibleTextViewTopAnchorConstraint,
        accessibleTextViewCenterYAnchorConstraint,
        accessibleTextViewBottomAnchorConstraint,
        imageViewHeightAnchorConstraint,
        imageViewWidthAnchorConstraint
      ] +
        conditionalConstraints(checkboxCircleViewIsHidden: checkboxCircleView.isHidden))
  }

  private func conditionalConstraints(checkboxCircleViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (checkboxCircleViewIsHidden) {
      case (true):
        constraints = []
      case (false):
        constraints = [
          checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint,
          checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint,
          checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint,
          checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let checkboxCircleViewIsHidden = checkboxCircleView.isHidden

    checkboxCircleView.isHidden = !true


    if checkboxValue {
      checkboxCircleView.isHidden = !true

    }
    if checkboxValue == false {
      checkboxCircleView.isHidden = !false

    }

    checkboxViewOnPress = handleOnToggleCheckbox

    if checkboxCircleView.isHidden != checkboxCircleViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(checkboxCircleViewIsHidden: checkboxCircleViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(checkboxCircleViewIsHidden: checkboxCircleView.isHidden))
    }
  }

  private func handleOnToggleCheckbox() {
    onToggleCheckbox?()
  }

  private func updateHoverState(with event: NSEvent) {
    let checkboxRowViewHovered = checkboxRowView
      .bounds
      .contains(checkboxRowView.convert(event.locationInWindow, from: nil))
    let checkboxViewHovered = checkboxView.bounds.contains(checkboxView.convert(event.locationInWindow, from: nil))
    if checkboxRowViewHovered != self.checkboxRowViewHovered || checkboxViewHovered != self.checkboxViewHovered {
      self.checkboxRowViewHovered = checkboxRowViewHovered
      self.checkboxViewHovered = checkboxViewHovered

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
    let checkboxRowViewPressed = checkboxRowView
      .bounds
      .contains(checkboxRowView.convert(event.locationInWindow, from: nil))
    let checkboxViewPressed = checkboxView.bounds.contains(checkboxView.convert(event.locationInWindow, from: nil))
    if checkboxRowViewPressed != self.checkboxRowViewPressed || checkboxViewPressed != self.checkboxViewPressed {
      self.checkboxRowViewPressed = checkboxRowViewPressed
      self.checkboxViewPressed = checkboxViewPressed

      update()
    }
  }

  public override func mouseUp(with event: NSEvent) {
    let checkboxRowViewClicked = checkboxRowViewPressed &&
      checkboxRowView.bounds.contains(checkboxRowView.convert(event.locationInWindow, from: nil))
    let checkboxViewClicked = checkboxViewPressed &&
      checkboxView.bounds.contains(checkboxView.convert(event.locationInWindow, from: nil))

    if checkboxRowViewPressed || checkboxViewPressed {
      checkboxRowViewPressed = false
      checkboxViewPressed = false

      update()
    }

    if checkboxRowViewClicked {
      checkboxRowViewOnPress?()
    }
    if checkboxViewClicked {
      checkboxViewOnPress?()
    }
  }
}

// MARK: - Parameters

extension AccessibilityTest {
  public struct Parameters: Equatable {
    public var customTextAccessibilityLabel: String
    public var checkboxValue: Bool
    public var onToggleCheckbox: (() -> Void)?

    public init(customTextAccessibilityLabel: String, checkboxValue: Bool, onToggleCheckbox: (() -> Void)? = nil) {
      self.customTextAccessibilityLabel = customTextAccessibilityLabel
      self.checkboxValue = checkboxValue
      self.onToggleCheckbox = onToggleCheckbox
    }

    public init() {
      self.init(customTextAccessibilityLabel: "", checkboxValue: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.customTextAccessibilityLabel == rhs.customTextAccessibilityLabel &&
        lhs.checkboxValue == rhs.checkboxValue
    }
  }
}

// MARK: - Model

extension AccessibilityTest {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "AccessibilityTest"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(customTextAccessibilityLabel: String, checkboxValue: Bool, onToggleCheckbox: (() -> Void)? = nil) {
      self
        .init(
          Parameters(
            customTextAccessibilityLabel: customTextAccessibilityLabel,
            checkboxValue: checkboxValue,
            onToggleCheckbox: onToggleCheckbox))
    }

    public init() {
      self.init(customTextAccessibilityLabel: "", checkboxValue: false)
    }
  }
}
