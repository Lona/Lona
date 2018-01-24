import UIKit
import Foundation

// MARK: - PrimaryAxis

public class PrimaryAxis: UIView {

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
  private var fill1View = UIView(frame: .zero)
  private var fill2View = UIView(frame: .zero)

  private var textViewTextStyle = TextStyles.body1

  private var topPadding: CGFloat = 24
  private var trailingPadding: CGFloat = 24
  private var bottomPadding: CGFloat = 24
  private var leadingPadding: CGFloat = 24
  private var fixedViewTopMargin: CGFloat = 0
  private var fixedViewTrailingMargin: CGFloat = 0
  private var fixedViewBottomMargin: CGFloat = 24
  private var fixedViewLeadingMargin: CGFloat = 0
  private var fitViewTopMargin: CGFloat = 0
  private var fitViewTrailingMargin: CGFloat = 0
  private var fitViewBottomMargin: CGFloat = 24
  private var fitViewLeadingMargin: CGFloat = 0
  private var fitViewTopPadding: CGFloat = 0
  private var fitViewTrailingPadding: CGFloat = 0
  private var fitViewBottomPadding: CGFloat = 0
  private var fitViewLeadingPadding: CGFloat = 0
  private var fill1ViewTopMargin: CGFloat = 0
  private var fill1ViewTrailingMargin: CGFloat = 0
  private var fill1ViewBottomMargin: CGFloat = 0
  private var fill1ViewLeadingMargin: CGFloat = 0
  private var fill2ViewTopMargin: CGFloat = 0
  private var fill2ViewTrailingMargin: CGFloat = 0
  private var fill2ViewBottomMargin: CGFloat = 0
  private var fill2ViewLeadingMargin: CGFloat = 0
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var fill1ViewHeightAnchorSiblingConstraint0: NSLayoutConstraint?
  private var fixedViewTopAnchorConstraint: NSLayoutConstraint?
  private var fixedViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fitViewTopAnchorConstraint: NSLayoutConstraint?
  private var fitViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fill1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var fill1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fill2ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var fill2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var fill2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fixedViewHeightAnchorConstraint: NSLayoutConstraint?
  private var fixedViewWidthAnchorConstraint: NSLayoutConstraint?
  private var fitViewWidthAnchorConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fill1ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var fill2ViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    addSubview(fixedView)
    addSubview(fitView)
    addSubview(fill1View)
    addSubview(fill2View)
    fitView.addSubview(textView)

    fixedView.backgroundColor =
      #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fitView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedText = textViewTextStyle.apply(to: "Text goes here")
    fill1View.backgroundColor = Colors.cyan500
    fill2View.backgroundColor = Colors.blue500
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    fixedView.translatesAutoresizingMaskIntoConstraints = false
    fitView.translatesAutoresizingMaskIntoConstraints = false
    fill1View.translatesAutoresizingMaskIntoConstraints = false
    fill2View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 500)
    let fill1ViewHeightAnchorSiblingConstraint0 = fill1View
      .heightAnchor
      .constraint(equalTo: fill2View.heightAnchor, constant: 0)
    let fixedViewTopAnchorConstraint = fixedView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + fixedViewTopMargin)
    let fixedViewLeadingAnchorConstraint = fixedView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fixedViewLeadingMargin)
    let fitViewTopAnchorConstraint = fitView
      .topAnchor
      .constraint(equalTo: fixedView.bottomAnchor, constant: fixedViewBottomMargin + fitViewTopMargin)
    let fitViewLeadingAnchorConstraint = fitView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fitViewLeadingMargin)
    let fill1ViewTopAnchorConstraint = fill1View
      .topAnchor
      .constraint(equalTo: fitView.bottomAnchor, constant: fitViewBottomMargin + fill1ViewTopMargin)
    let fill1ViewLeadingAnchorConstraint = fill1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fill1ViewLeadingMargin)
    let fill2ViewBottomAnchorConstraint = fill2View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + fill2ViewBottomMargin))
    let fill2ViewTopAnchorConstraint = fill2View
      .topAnchor
      .constraint(equalTo: fill1View.bottomAnchor, constant: fill1ViewBottomMargin + fill2ViewTopMargin)
    let fill2ViewLeadingAnchorConstraint = fill2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fill2ViewLeadingMargin)
    let fixedViewHeightAnchorConstraint = fixedView.heightAnchor.constraint(equalToConstant: 100)
    let fixedViewWidthAnchorConstraint = fixedView.widthAnchor.constraint(equalToConstant: 100)
    let fitViewWidthAnchorConstraint = fitView.widthAnchor.constraint(equalToConstant: 100)
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: fitView.topAnchor, constant: fitViewTopPadding + textViewTopMargin)
    let textViewBottomAnchorConstraint = textView
      .bottomAnchor
      .constraint(equalTo: fitView.bottomAnchor, constant: -(fitViewBottomPadding + textViewBottomMargin))
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: fitView.leadingAnchor, constant: fitViewLeadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: fitView.trailingAnchor, constant: -(fitViewTrailingPadding + textViewTrailingMargin))
    let fill1ViewWidthAnchorConstraint = fill1View.widthAnchor.constraint(equalToConstant: 100)
    let fill2ViewWidthAnchorConstraint = fill2View.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      fill1ViewHeightAnchorSiblingConstraint0,
      fixedViewTopAnchorConstraint,
      fixedViewLeadingAnchorConstraint,
      fitViewTopAnchorConstraint,
      fitViewLeadingAnchorConstraint,
      fill1ViewTopAnchorConstraint,
      fill1ViewLeadingAnchorConstraint,
      fill2ViewBottomAnchorConstraint,
      fill2ViewTopAnchorConstraint,
      fill2ViewLeadingAnchorConstraint,
      fixedViewHeightAnchorConstraint,
      fixedViewWidthAnchorConstraint,
      fitViewWidthAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      fill1ViewWidthAnchorConstraint,
      fill2ViewWidthAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.fill1ViewHeightAnchorSiblingConstraint0 = fill1ViewHeightAnchorSiblingConstraint0
    self.fixedViewTopAnchorConstraint = fixedViewTopAnchorConstraint
    self.fixedViewLeadingAnchorConstraint = fixedViewLeadingAnchorConstraint
    self.fitViewTopAnchorConstraint = fitViewTopAnchorConstraint
    self.fitViewLeadingAnchorConstraint = fitViewLeadingAnchorConstraint
    self.fill1ViewTopAnchorConstraint = fill1ViewTopAnchorConstraint
    self.fill1ViewLeadingAnchorConstraint = fill1ViewLeadingAnchorConstraint
    self.fill2ViewBottomAnchorConstraint = fill2ViewBottomAnchorConstraint
    self.fill2ViewTopAnchorConstraint = fill2ViewTopAnchorConstraint
    self.fill2ViewLeadingAnchorConstraint = fill2ViewLeadingAnchorConstraint
    self.fixedViewHeightAnchorConstraint = fixedViewHeightAnchorConstraint
    self.fixedViewWidthAnchorConstraint = fixedViewWidthAnchorConstraint
    self.fitViewWidthAnchorConstraint = fitViewWidthAnchorConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.fill1ViewWidthAnchorConstraint = fill1ViewWidthAnchorConstraint
    self.fill2ViewWidthAnchorConstraint = fill2ViewWidthAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    fill1ViewHeightAnchorSiblingConstraint0.identifier = "fill1ViewHeightAnchorSiblingConstraint0"
    fixedViewTopAnchorConstraint.identifier = "fixedViewTopAnchorConstraint"
    fixedViewLeadingAnchorConstraint.identifier = "fixedViewLeadingAnchorConstraint"
    fitViewTopAnchorConstraint.identifier = "fitViewTopAnchorConstraint"
    fitViewLeadingAnchorConstraint.identifier = "fitViewLeadingAnchorConstraint"
    fill1ViewTopAnchorConstraint.identifier = "fill1ViewTopAnchorConstraint"
    fill1ViewLeadingAnchorConstraint.identifier = "fill1ViewLeadingAnchorConstraint"
    fill2ViewBottomAnchorConstraint.identifier = "fill2ViewBottomAnchorConstraint"
    fill2ViewTopAnchorConstraint.identifier = "fill2ViewTopAnchorConstraint"
    fill2ViewLeadingAnchorConstraint.identifier = "fill2ViewLeadingAnchorConstraint"
    fixedViewHeightAnchorConstraint.identifier = "fixedViewHeightAnchorConstraint"
    fixedViewWidthAnchorConstraint.identifier = "fixedViewWidthAnchorConstraint"
    fitViewWidthAnchorConstraint.identifier = "fitViewWidthAnchorConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewBottomAnchorConstraint.identifier = "textViewBottomAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    fill1ViewWidthAnchorConstraint.identifier = "fill1ViewWidthAnchorConstraint"
    fill2ViewWidthAnchorConstraint.identifier = "fill2ViewWidthAnchorConstraint"
  }

  private func update() {}
}