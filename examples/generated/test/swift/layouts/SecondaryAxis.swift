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

  // MARK: Public


  // MARK: Private

  private var fixedView = UIView(frame: .zero)
  private var fitView = UIView(frame: .zero)
  private var textView = UILabel()
  private var fillView = UIView(frame: .zero)

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
  private var fitViewTopPadding: CGFloat = 12
  private var fitViewTrailingPadding: CGFloat = 12
  private var fitViewBottomPadding: CGFloat = 12
  private var fitViewLeadingPadding: CGFloat = 12
  private var fillViewTopMargin: CGFloat = 0
  private var fillViewTrailingMargin: CGFloat = 0
  private var fillViewBottomMargin: CGFloat = 0
  private var fillViewLeadingMargin: CGFloat = 0
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var fixedViewTopAnchorConstraint: NSLayoutConstraint?
  private var fixedViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fitViewTopAnchorConstraint: NSLayoutConstraint?
  private var fitViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fitViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fillViewBottomAnchorConstraint: NSLayoutConstraint?
  private var fillViewTopAnchorConstraint: NSLayoutConstraint?
  private var fillViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fillViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fixedViewHeightAnchorConstraint: NSLayoutConstraint?
  private var fixedViewWidthAnchorConstraint: NSLayoutConstraint?
  private var fitViewHeightAnchorConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var textViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var fillViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    addSubview(fixedView)
    addSubview(fitView)
    addSubview(fillView)
    fitView.addSubview(textView)

    fixedView.backgroundColor =
    #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fitView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.text = "Text goes here"
    fillView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    fixedView.translatesAutoresizingMaskIntoConstraints = false
    fitView.translatesAutoresizingMaskIntoConstraints = false
    fillView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

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
    let fitViewTrailingAnchorConstraint = fitView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + fitViewTrailingMargin))
    let fillViewBottomAnchorConstraint = fillView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + fillViewBottomMargin))
    let fillViewTopAnchorConstraint = fillView
      .topAnchor
      .constraint(equalTo: fitView.bottomAnchor, constant: fitViewBottomMargin + fillViewTopMargin)
    let fillViewLeadingAnchorConstraint = fillView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fillViewLeadingMargin)
    let fillViewTrailingAnchorConstraint = fillView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + fillViewTrailingMargin))
    let fixedViewHeightAnchorConstraint = fixedView.heightAnchor.constraint(equalToConstant: 100)
    let fixedViewWidthAnchorConstraint = fixedView.widthAnchor.constraint(equalToConstant: 100)
    let fitViewHeightAnchorConstraint = fitView.heightAnchor.constraint(equalToConstant: 100)
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: fitView.topAnchor, constant: fitViewTopPadding + textViewTopMargin)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: fitView.leadingAnchor, constant: fitViewLeadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: fitView.trailingAnchor, constant: -(fitViewTrailingPadding + textViewTrailingMargin))
    let textViewWidthAnchorParentConstraint = textView
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: fitView.widthAnchor,
        constant: -(fitViewLeadingPadding + textViewLeadingMargin + fitViewTrailingPadding + textViewTrailingMargin))
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
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      textViewWidthAnchorParentConstraint,
      fillViewHeightAnchorConstraint
    ])

    self.fixedViewTopAnchorConstraint = fixedViewTopAnchorConstraint
    self.fixedViewLeadingAnchorConstraint = fixedViewLeadingAnchorConstraint
    self.fitViewTopAnchorConstraint = fitViewTopAnchorConstraint
    self.fitViewLeadingAnchorConstraint = fitViewLeadingAnchorConstraint
    self.fitViewTrailingAnchorConstraint = fitViewTrailingAnchorConstraint
    self.fillViewBottomAnchorConstraint = fillViewBottomAnchorConstraint
    self.fillViewTopAnchorConstraint = fillViewTopAnchorConstraint
    self.fillViewLeadingAnchorConstraint = fillViewLeadingAnchorConstraint
    self.fillViewTrailingAnchorConstraint = fillViewTrailingAnchorConstraint
    self.fixedViewHeightAnchorConstraint = fixedViewHeightAnchorConstraint
    self.fixedViewWidthAnchorConstraint = fixedViewWidthAnchorConstraint
    self.fitViewHeightAnchorConstraint = fitViewHeightAnchorConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.textViewWidthAnchorParentConstraint = textViewWidthAnchorParentConstraint
    self.fillViewHeightAnchorConstraint = fillViewHeightAnchorConstraint

    // For debugging
    fixedViewTopAnchorConstraint.identifier = "fixedViewTopAnchorConstraint"
    fixedViewLeadingAnchorConstraint.identifier = "fixedViewLeadingAnchorConstraint"
    fitViewTopAnchorConstraint.identifier = "fitViewTopAnchorConstraint"
    fitViewLeadingAnchorConstraint.identifier = "fitViewLeadingAnchorConstraint"
    fitViewTrailingAnchorConstraint.identifier = "fitViewTrailingAnchorConstraint"
    fillViewBottomAnchorConstraint.identifier = "fillViewBottomAnchorConstraint"
    fillViewTopAnchorConstraint.identifier = "fillViewTopAnchorConstraint"
    fillViewLeadingAnchorConstraint.identifier = "fillViewLeadingAnchorConstraint"
    fillViewTrailingAnchorConstraint.identifier = "fillViewTrailingAnchorConstraint"
    fixedViewHeightAnchorConstraint.identifier = "fixedViewHeightAnchorConstraint"
    fixedViewWidthAnchorConstraint.identifier = "fixedViewWidthAnchorConstraint"
    fitViewHeightAnchorConstraint.identifier = "fitViewHeightAnchorConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    textViewWidthAnchorParentConstraint.identifier = "textViewWidthAnchorParentConstraint"
    fillViewHeightAnchorConstraint.identifier = "fillViewHeightAnchorConstraint"
  }

  private func update() {}
}