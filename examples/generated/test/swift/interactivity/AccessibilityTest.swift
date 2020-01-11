import UIKit
import Foundation

// MARK: - BackgroundImageView

private class BackgroundImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
  }
}

// MARK: - EventIgnoringView

private class EventIgnoringView: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for view in subviews {
      if view.isUserInteractionEnabled && view.point(inside: convert(point, to: view), with: event) {
        return true
      }
    }
    return false
  }
}

// MARK: - AccessibilityTest

public class AccessibilityTest: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
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

  private var checkboxRowView = LonaControlView(frame: .zero)
  private var checkboxView = LonaControlView(frame: .zero)
  private var checkboxCircleView = EventIgnoringView(frame: .zero)
  private var textView = UILabel()
  private var row1View = EventIgnoringView(frame: .zero)
  private var elementView = EventIgnoringView(frame: .zero)
  private var innerView = EventIgnoringView(frame: .zero)
  private var containerView = EventIgnoringView(frame: .zero)
  private var imageView = BackgroundImageView(frame: .zero)
  private var accessibleTextView = UILabel()

  private var textViewTextStyle = TextStyles.body1
  private var accessibleTextViewTextStyle = TextStyles.body1

  private var onTapCheckboxRowView: (() -> Void)?
  private var onTapCheckboxView: (() -> Void)?

  private var checkboxCircleViewTopAnchorCheckboxViewTopAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewBottomAnchorCheckboxViewBottomAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewLeadingAnchorCheckboxViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var checkboxCircleViewTrailingAnchorCheckboxViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    textView.isUserInteractionEnabled = false
    textView.numberOfLines = 0
    imageView.isUserInteractionEnabled = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    accessibleTextView.isUserInteractionEnabled = false
    accessibleTextView.numberOfLines = 0

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

    checkboxRowView.isAccessibilityElement = true
    checkboxRowView.accessibilityLabel = "Checkbox row"
    checkboxRowView.accessibilityTraits = UIAccessibilityTraits.button
    checkboxView.layer.borderColor = Colors.grey400.cgColor
    checkboxView.layer.cornerRadius = 20
    checkboxView.layer.borderWidth = 1
    checkboxCircleView.backgroundColor = Colors.green200
    checkboxCircleView.layer.cornerRadius = 15
    textView.attributedText = textViewTextStyle.apply(to: "Checkbox description")
    elementView.backgroundColor = Colors.red600
    elementView.isAccessibilityElement = true
    elementView.accessibilityLabel = "Red box"
    elementView.accessibilityHint = "An accessibility element"
    elementView.accessibilityTraits = UIAccessibilityTraits.button
    innerView.backgroundColor = Colors.red800
    containerView.isAccessibilityElement = false
    containerView.accessibilityElements = [accessibleTextView, imageView]
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.isAccessibilityElement = true
    imageView.accessibilityLabel = "My image"
    imageView.accessibilityHint = "A cool image"
    accessibleTextView.attributedText = accessibleTextViewTextStyle.apply(to: "Greetings")
    accessibleTextView.isAccessibilityElement = true
    accessibleTextView.accessibilityHint = "Some text"

    checkboxRowView.addTarget(self, action: #selector(handleTapCheckboxRowView), for: .touchUpInside)
    checkboxRowView.onHighlight = update
    checkboxView.addTarget(self, action: #selector(handleTapCheckboxView), for: .touchUpInside)
    checkboxView.onHighlight = update
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

    checkboxViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    textViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    elementViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    containerViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    imageViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    accessibleTextViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow

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
    checkboxRowView.accessibilityValue = ""
    accessibleTextView.accessibilityLabel = customTextAccessibilityLabel
    if checkboxValue {
      checkboxCircleView.isHidden = !true
      checkboxRowView.accessibilityValue = "checked"
    }
    if checkboxValue == false {
      checkboxCircleView.isHidden = !false
      checkboxRowView.accessibilityValue = "unchecked"
    }
    checkboxRowView.onAccessibilityActivate = handleOnToggleCheckbox
    onTapCheckboxView = handleOnToggleCheckbox


    if checkboxCircleView.isHidden != checkboxCircleViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(checkboxCircleViewIsHidden: checkboxCircleViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(checkboxCircleViewIsHidden: checkboxCircleView.isHidden))
    }
  }

  private func handleOnToggleCheckbox() {
    onToggleCheckbox?()
  }

  @objc private func handleTapCheckboxRowView() {
    onTapCheckboxRowView?()
  }

  @objc private func handleTapCheckboxView() {
    onTapCheckboxView?()
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
