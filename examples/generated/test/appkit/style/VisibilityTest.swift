import AppKit
import Foundation

// MARK: - VisibilityTest

public class VisibilityTest: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(enabled: Bool) {
    self.init(Parameters(enabled: enabled))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var enabled: Bool {
    get { return parameters.enabled }
    set { parameters.enabled = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var viewView = NSBox()

  private var titleViewTextStyle = TextStyles.body1

  private var viewViewTopAnchorTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewTopAnchorTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var viewViewTopAnchorInnerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var innerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var viewViewTopAnchorTitleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorInnerViewBottomAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero

    addSubview(innerView)
    addSubview(titleView)
    addSubview(viewView)

    innerView.isHidden = !false
    innerView.fillColor = Colors.green300
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Enabled")
    viewView.fillColor = Colors.blue300
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false

    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let viewViewLeadingAnchorConstraint = viewView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let viewViewHeightAnchorConstraint = viewView.heightAnchor.constraint(equalToConstant: 100)
    let viewViewWidthAnchorConstraint = viewView.widthAnchor.constraint(equalToConstant: 100)
    let viewViewTopAnchorTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewTopAnchorTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewLeadingAnchorLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let viewViewTopAnchorInnerViewBottomAnchorConstraint = viewView
      .topAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)
    let titleViewTopAnchorTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor)
    let titleViewLeadingAnchorLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor)
    let viewViewTopAnchorTitleViewBottomAnchorConstraint = viewView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor)
    let titleViewTopAnchorInnerViewBottomAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: innerView.bottomAnchor)

    NSLayoutConstraint.activate([
      viewViewBottomAnchorConstraint,
      viewViewLeadingAnchorConstraint,
      viewViewHeightAnchorConstraint,
      viewViewWidthAnchorConstraint
    ])

    self.viewViewTopAnchorTopAnchorConstraint = viewViewTopAnchorTopAnchorConstraint
    self.innerViewTopAnchorTopAnchorConstraint = innerViewTopAnchorTopAnchorConstraint
    self.innerViewLeadingAnchorLeadingAnchorConstraint = innerViewLeadingAnchorLeadingAnchorConstraint
    self.viewViewTopAnchorInnerViewBottomAnchorConstraint = viewViewTopAnchorInnerViewBottomAnchorConstraint
    self.innerViewHeightAnchorConstraint = innerViewHeightAnchorConstraint
    self.innerViewWidthAnchorConstraint = innerViewWidthAnchorConstraint
    self.titleViewTopAnchorTopAnchorConstraint = titleViewTopAnchorTopAnchorConstraint
    self.titleViewLeadingAnchorLeadingAnchorConstraint = titleViewLeadingAnchorLeadingAnchorConstraint
    self.titleViewTrailingAnchorTrailingAnchorConstraint = titleViewTrailingAnchorTrailingAnchorConstraint
    self.viewViewTopAnchorTitleViewBottomAnchorConstraint = viewViewTopAnchorTitleViewBottomAnchorConstraint
    self.titleViewTopAnchorInnerViewBottomAnchorConstraint = titleViewTopAnchorInnerViewBottomAnchorConstraint
  }

  private func conditionalConstraints() -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (innerView.isHidden, titleView.isHidden) {
      case (true, true):
        constraints = [viewViewTopAnchorTopAnchorConstraint]
      case (false, true):
        constraints = [
          innerViewTopAnchorTopAnchorConstraint,
          innerViewLeadingAnchorLeadingAnchorConstraint,
          viewViewTopAnchorInnerViewBottomAnchorConstraint,
          innerViewHeightAnchorConstraint,
          innerViewWidthAnchorConstraint
        ]
      case (true, false):
        constraints = [
          titleViewTopAnchorTopAnchorConstraint,
          titleViewLeadingAnchorLeadingAnchorConstraint,
          titleViewTrailingAnchorTrailingAnchorConstraint,
          viewViewTopAnchorTitleViewBottomAnchorConstraint
        ]
      case (false, false):
        constraints = [
          innerViewTopAnchorTopAnchorConstraint,
          innerViewLeadingAnchorLeadingAnchorConstraint,
          titleViewTopAnchorInnerViewBottomAnchorConstraint,
          titleViewLeadingAnchorLeadingAnchorConstraint,
          titleViewTrailingAnchorTrailingAnchorConstraint,
          viewViewTopAnchorTitleViewBottomAnchorConstraint,
          innerViewHeightAnchorConstraint,
          innerViewWidthAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    NSLayoutConstraint.deactivate(conditionalConstraints())

    titleView.isHidden = !enabled

    NSLayoutConstraint.activate(conditionalConstraints())
  }
}

// MARK: - Parameters

extension VisibilityTest {
  public struct Parameters: Equatable {
    public var enabled: Bool

    public init(enabled: Bool) {
      self.enabled = enabled
    }

    public init() {
      self.init(enabled: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.enabled == rhs.enabled
    }
  }
}

// MARK: - Model

extension VisibilityTest {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "VisibilityTest"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(enabled: Bool) {
      self.init(Parameters(enabled: enabled))
    }

    public init() {
      self.init(enabled: false)
    }
  }
}
