import UIKit
import Foundation

// MARK: - PressableRootView

public class PressableRootView: LonaControlView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onPressOuter: (() -> Void)? {
    get { return parameters.onPressOuter }
    set { parameters.onPressOuter = newValue }
  }

  public var onPressInner: (() -> Void)? {
    get { return parameters.onPressInner }
    set { parameters.onPressInner = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var innerView = LonaControlView(frame: .zero)
  private var innerTextView = UILabel()

  private var innerTextViewTextStyle = TextStyles.headline

  private var onTapOuterView: (() -> Void)?
  private var onTapInnerView: (() -> Void)?

  private func setUpViews() {
    innerTextView.numberOfLines = 0

    addSubview(innerView)
    innerView.addSubview(innerTextView)

    innerTextViewTextStyle = TextStyles.headline
    innerTextView.attributedText =
      innerTextViewTextStyle.apply(to: innerTextView.attributedText ?? NSAttributedString())

    addTarget(self, action: #selector(handleTapOuterView), for: .touchUpInside)
    onHighlight = update
    innerView.addTarget(self, action: #selector(handleTapInnerView), for: .touchUpInside)
    innerView.onHighlight = update
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    innerTextView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)
    let innerTextViewTopAnchorConstraint = innerTextView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let innerTextViewLeadingAnchorConstraint = innerTextView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let innerTextViewTrailingAnchorConstraint = innerTextView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint,
      innerTextViewTopAnchorConstraint,
      innerTextViewLeadingAnchorConstraint,
      innerTextViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    innerView.backgroundColor = Colors.blue500
    innerTextView.attributedText = innerTextViewTextStyle.apply(to: "")
    backgroundColor = Colors.grey50
    onTapOuterView = onPressOuter
    onTapInnerView = onPressInner

    if showsHighlight {
      backgroundColor = Colors.grey300
    }

    if innerView.showsHighlight {
      innerView.backgroundColor = Colors.blue800
      innerTextView.attributedText = innerTextViewTextStyle.apply(to: "Pressed")
    }

  }

  @objc private func handleTapOuterView() {
    onTapOuterView?()
  }

  @objc private func handleTapInnerView() {
    onTapInnerView?()
  }

  public var isRootControlTrackingEnabled = true

  override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let result = super.hitTest(point, with: event)
    if result == self && !isRootControlTrackingEnabled {
      return nil
    }
    return result
  }
}

// MARK: - Parameters

extension PressableRootView {
  public struct Parameters: Equatable {
    public var onPressOuter: (() -> Void)?
    public var onPressInner: (() -> Void)?

    public init(onPressOuter: (() -> Void)? = nil, onPressInner: (() -> Void)? = nil) {
      self.onPressOuter = onPressOuter
      self.onPressInner = onPressInner
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return true
    }
  }
}

// MARK: - Model

extension PressableRootView {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "PressableRootView"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(onPressOuter: (() -> Void)? = nil, onPressInner: (() -> Void)? = nil) {
      self.init(Parameters(onPressOuter: onPressOuter, onPressInner: onPressInner))
    }
  }
}
