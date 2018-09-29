import UIKit
import Foundation

// MARK: - SecondaryAxis

public class SecondaryAxis: UIView {

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

  // MARK: Private

  private var fixedView = UIView(frame: .zero)
  private var fitView = UIView(frame: .zero)
  private var textView = UILabel()
  private var fillView = UIView(frame: .zero)

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    textView.numberOfLines = 0

    addSubview(fixedView)
    addSubview(fitView)
    addSubview(fillView)
    fitView.addSubview(textView)

    fixedView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fitView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedText = textViewTextStyle.apply(to: "Text goes here")
    fillView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    fixedView.translatesAutoresizingMaskIntoConstraints = false
    fitView.translatesAutoresizingMaskIntoConstraints = false
    fillView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let fixedViewTopAnchorConstraint = fixedView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let fixedViewLeadingAnchorConstraint = fixedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fitViewTopAnchorConstraint = fitView.topAnchor.constraint(equalTo: fixedView.bottomAnchor, constant: 24)
    let fitViewLeadingAnchorConstraint = fitView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fitViewTrailingAnchorConstraint = fitView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
    let fillViewBottomAnchorConstraint = fillView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
    let fillViewTopAnchorConstraint = fillView.topAnchor.constraint(equalTo: fitView.bottomAnchor, constant: 24)
    let fillViewLeadingAnchorConstraint = fillView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fillViewTrailingAnchorConstraint = fillView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
    let fixedViewHeightAnchorConstraint = fixedView.heightAnchor.constraint(equalToConstant: 100)
    let fixedViewWidthAnchorConstraint = fixedView.widthAnchor.constraint(equalToConstant: 100)
    let fitViewHeightAnchorConstraint = fitView.heightAnchor.constraint(equalToConstant: 100)
    let textViewWidthAnchorParentConstraint = textView
      .widthAnchor
      .constraint(lessThanOrEqualTo: fitView.widthAnchor, constant: -(12 + 12))
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: fitView.topAnchor, constant: 12)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: fitView.leadingAnchor, constant: 12)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: fitView.trailingAnchor, constant: -12)
    let fillViewHeightAnchorConstraint = fillView.heightAnchor.constraint(equalToConstant: 100)

    textViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      fixedViewTopAnchorConstraint,
      fixedViewLeadingAnchorConstraint,
      fitViewTopAnchorConstraint,
      fitViewLeadingAnchorConstraint,
      fitViewTrailingAnchorConstraint,
      fillViewBottomAnchorConstraint,
      fillViewTopAnchorConstraint,
      fillViewLeadingAnchorConstraint,
      fillViewTrailingAnchorConstraint,
      fixedViewHeightAnchorConstraint,
      fixedViewWidthAnchorConstraint,
      fitViewHeightAnchorConstraint,
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      fillViewHeightAnchorConstraint
    ])
  }

  private func update() {}
}
