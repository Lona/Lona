import UIKit
import Foundation

// MARK: - PressableRootView

public class PressableRootView: LonaControlView {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onPressOuter: (() -> Void)? { didSet { update() } }
  public var onPressInner: (() -> Void)? { didSet { update() } }

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

    if isHighlighted {
      backgroundColor = Colors.grey300
    }

    if innerView.isHighlighted {
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
}
