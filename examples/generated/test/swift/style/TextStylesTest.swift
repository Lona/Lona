import UIKit
import Foundation

// MARK: - TextStylesTest

public class TextStylesTest: UIView {

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

  private var textView = UILabel()
  private var text1View = UILabel()
  private var text2View = UILabel()
  private var text3View = UILabel()
  private var text4View = UILabel()
  private var text5View = UILabel()
  private var text6View = UILabel()
  private var text7View = UILabel()
  private var text8View = UILabel()
  private var text9View = UILabel()

  private var textViewTextStyle = TextStyles.display4
  private var text1ViewTextStyle = TextStyles.display3
  private var text2ViewTextStyle = TextStyles.display2
  private var text3ViewTextStyle = TextStyles.display1
  private var text4ViewTextStyle = TextStyles.headline
  private var text5ViewTextStyle = TextStyles.subheading2
  private var text6ViewTextStyle = TextStyles.subheading1
  private var text7ViewTextStyle = TextStyles.body2
  private var text8ViewTextStyle = TextStyles.body1
  private var text9ViewTextStyle = TextStyles.caption

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0
  private var text1ViewTopMargin: CGFloat = 0
  private var text1ViewTrailingMargin: CGFloat = 0
  private var text1ViewBottomMargin: CGFloat = 0
  private var text1ViewLeadingMargin: CGFloat = 0
  private var text2ViewTopMargin: CGFloat = 0
  private var text2ViewTrailingMargin: CGFloat = 0
  private var text2ViewBottomMargin: CGFloat = 0
  private var text2ViewLeadingMargin: CGFloat = 0
  private var text3ViewTopMargin: CGFloat = 0
  private var text3ViewTrailingMargin: CGFloat = 0
  private var text3ViewBottomMargin: CGFloat = 0
  private var text3ViewLeadingMargin: CGFloat = 0
  private var text4ViewTopMargin: CGFloat = 0
  private var text4ViewTrailingMargin: CGFloat = 0
  private var text4ViewBottomMargin: CGFloat = 0
  private var text4ViewLeadingMargin: CGFloat = 0
  private var text5ViewTopMargin: CGFloat = 0
  private var text5ViewTrailingMargin: CGFloat = 0
  private var text5ViewBottomMargin: CGFloat = 0
  private var text5ViewLeadingMargin: CGFloat = 0
  private var text6ViewTopMargin: CGFloat = 0
  private var text6ViewTrailingMargin: CGFloat = 0
  private var text6ViewBottomMargin: CGFloat = 0
  private var text6ViewLeadingMargin: CGFloat = 0
  private var text7ViewTopMargin: CGFloat = 0
  private var text7ViewTrailingMargin: CGFloat = 0
  private var text7ViewBottomMargin: CGFloat = 0
  private var text7ViewLeadingMargin: CGFloat = 0
  private var text8ViewTopMargin: CGFloat = 0
  private var text8ViewTrailingMargin: CGFloat = 0
  private var text8ViewBottomMargin: CGFloat = 0
  private var text8ViewLeadingMargin: CGFloat = 0
  private var text9ViewTopMargin: CGFloat = 0
  private var text9ViewTrailingMargin: CGFloat = 0
  private var text9ViewBottomMargin: CGFloat = 0
  private var text9ViewLeadingMargin: CGFloat = 0

  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text3ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text4ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text4ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text4ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text5ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text5ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text5ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text6ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text6ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text6ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text7ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text7ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text7ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text8ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text8ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text8ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text9ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text9ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text9ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text9ViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    textView.numberOfLines = 0
    text1View.numberOfLines = 0
    text2View.numberOfLines = 0
    text3View.numberOfLines = 0
    text4View.numberOfLines = 0
    text5View.numberOfLines = 0
    text6View.numberOfLines = 0
    text7View.numberOfLines = 0
    text8View.numberOfLines = 0
    text9View.numberOfLines = 0

    addSubview(textView)
    addSubview(text1View)
    addSubview(text2View)
    addSubview(text3View)
    addSubview(text4View)
    addSubview(text5View)
    addSubview(text6View)
    addSubview(text7View)
    addSubview(text8View)
    addSubview(text9View)

    textViewTextStyle = TextStyles.display4
    textView.attributedText = textViewTextStyle.apply(to: textView.attributedText)
    textView.attributedText = textViewTextStyle.apply(to: "Text goes here")
    text1ViewTextStyle = TextStyles.display3
    text1View.attributedText = text1ViewTextStyle.apply(to: text1View.attributedText)
    text1View.attributedText = text1ViewTextStyle.apply(to: "Text goes here")
    text2ViewTextStyle = TextStyles.display2
    text2View.attributedText = text2ViewTextStyle.apply(to: text2View.attributedText)
    text2View.attributedText = text2ViewTextStyle.apply(to: "Text goes here")
    text3ViewTextStyle = TextStyles.display1
    text3View.attributedText = text3ViewTextStyle.apply(to: text3View.attributedText)
    text3View.attributedText = text3ViewTextStyle.apply(to: "Text goes here")
    text4ViewTextStyle = TextStyles.headline
    text4View.attributedText = text4ViewTextStyle.apply(to: text4View.attributedText)
    text4View.attributedText = text4ViewTextStyle.apply(to: "Text goes here")
    text5ViewTextStyle = TextStyles.subheading2
    text5View.attributedText = text5ViewTextStyle.apply(to: text5View.attributedText)
    text5View.attributedText = text5ViewTextStyle.apply(to: "Text goes here")
    text6ViewTextStyle = TextStyles.subheading1
    text6View.attributedText = text6ViewTextStyle.apply(to: text6View.attributedText)
    text6View.attributedText = text6ViewTextStyle.apply(to: "Text goes here")
    text7ViewTextStyle = TextStyles.body2
    text7View.attributedText = text7ViewTextStyle.apply(to: text7View.attributedText)
    text7View.attributedText = text7ViewTextStyle.apply(to: "Text goes here")
    text8ViewTextStyle = TextStyles.body1
    text8View.attributedText = text8ViewTextStyle.apply(to: text8View.attributedText)
    text8View.attributedText = text8ViewTextStyle.apply(to: "Text goes here")
    text9ViewTextStyle = TextStyles.caption
    text9View.attributedText = text9ViewTextStyle.apply(to: text9View.attributedText)
    text9View.attributedText = text9ViewTextStyle.apply(to: "Text goes here")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    text2View.translatesAutoresizingMaskIntoConstraints = false
    text3View.translatesAutoresizingMaskIntoConstraints = false
    text4View.translatesAutoresizingMaskIntoConstraints = false
    text5View.translatesAutoresizingMaskIntoConstraints = false
    text6View.translatesAutoresizingMaskIntoConstraints = false
    text7View.translatesAutoresizingMaskIntoConstraints = false
    text8View.translatesAutoresizingMaskIntoConstraints = false
    text9View.translatesAutoresizingMaskIntoConstraints = false

    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + textViewTopMargin)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))
    let text1ViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(equalTo: textView.bottomAnchor, constant: textViewBottomMargin + text1ViewTopMargin)
    let text1ViewLeadingAnchorConstraint = text1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text1ViewLeadingMargin)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text1ViewTrailingMargin))
    let text2ViewTopAnchorConstraint = text2View
      .topAnchor
      .constraint(equalTo: text1View.bottomAnchor, constant: text1ViewBottomMargin + text2ViewTopMargin)
    let text2ViewLeadingAnchorConstraint = text2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text2ViewLeadingMargin)
    let text2ViewTrailingAnchorConstraint = text2View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text2ViewTrailingMargin))
    let text3ViewTopAnchorConstraint = text3View
      .topAnchor
      .constraint(equalTo: text2View.bottomAnchor, constant: text2ViewBottomMargin + text3ViewTopMargin)
    let text3ViewLeadingAnchorConstraint = text3View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text3ViewLeadingMargin)
    let text3ViewTrailingAnchorConstraint = text3View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text3ViewTrailingMargin))
    let text4ViewTopAnchorConstraint = text4View
      .topAnchor
      .constraint(equalTo: text3View.bottomAnchor, constant: text3ViewBottomMargin + text4ViewTopMargin)
    let text4ViewLeadingAnchorConstraint = text4View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text4ViewLeadingMargin)
    let text4ViewTrailingAnchorConstraint = text4View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text4ViewTrailingMargin))
    let text5ViewTopAnchorConstraint = text5View
      .topAnchor
      .constraint(equalTo: text4View.bottomAnchor, constant: text4ViewBottomMargin + text5ViewTopMargin)
    let text5ViewLeadingAnchorConstraint = text5View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text5ViewLeadingMargin)
    let text5ViewTrailingAnchorConstraint = text5View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text5ViewTrailingMargin))
    let text6ViewTopAnchorConstraint = text6View
      .topAnchor
      .constraint(equalTo: text5View.bottomAnchor, constant: text5ViewBottomMargin + text6ViewTopMargin)
    let text6ViewLeadingAnchorConstraint = text6View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text6ViewLeadingMargin)
    let text6ViewTrailingAnchorConstraint = text6View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text6ViewTrailingMargin))
    let text7ViewTopAnchorConstraint = text7View
      .topAnchor
      .constraint(equalTo: text6View.bottomAnchor, constant: text6ViewBottomMargin + text7ViewTopMargin)
    let text7ViewLeadingAnchorConstraint = text7View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text7ViewLeadingMargin)
    let text7ViewTrailingAnchorConstraint = text7View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text7ViewTrailingMargin))
    let text8ViewTopAnchorConstraint = text8View
      .topAnchor
      .constraint(equalTo: text7View.bottomAnchor, constant: text7ViewBottomMargin + text8ViewTopMargin)
    let text8ViewLeadingAnchorConstraint = text8View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text8ViewLeadingMargin)
    let text8ViewTrailingAnchorConstraint = text8View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text8ViewTrailingMargin))
    let text9ViewBottomAnchorConstraint = text9View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + text9ViewBottomMargin))
    let text9ViewTopAnchorConstraint = text9View
      .topAnchor
      .constraint(equalTo: text8View.bottomAnchor, constant: text8ViewBottomMargin + text9ViewTopMargin)
    let text9ViewLeadingAnchorConstraint = text9View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text9ViewLeadingMargin)
    let text9ViewTrailingAnchorConstraint = text9View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text9ViewTrailingMargin))

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      text2ViewTopAnchorConstraint,
      text2ViewLeadingAnchorConstraint,
      text2ViewTrailingAnchorConstraint,
      text3ViewTopAnchorConstraint,
      text3ViewLeadingAnchorConstraint,
      text3ViewTrailingAnchorConstraint,
      text4ViewTopAnchorConstraint,
      text4ViewLeadingAnchorConstraint,
      text4ViewTrailingAnchorConstraint,
      text5ViewTopAnchorConstraint,
      text5ViewLeadingAnchorConstraint,
      text5ViewTrailingAnchorConstraint,
      text6ViewTopAnchorConstraint,
      text6ViewLeadingAnchorConstraint,
      text6ViewTrailingAnchorConstraint,
      text7ViewTopAnchorConstraint,
      text7ViewLeadingAnchorConstraint,
      text7ViewTrailingAnchorConstraint,
      text8ViewTopAnchorConstraint,
      text8ViewLeadingAnchorConstraint,
      text8ViewTrailingAnchorConstraint,
      text9ViewBottomAnchorConstraint,
      text9ViewTopAnchorConstraint,
      text9ViewLeadingAnchorConstraint,
      text9ViewTrailingAnchorConstraint
    ])

    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.text1ViewTopAnchorConstraint = text1ViewTopAnchorConstraint
    self.text1ViewLeadingAnchorConstraint = text1ViewLeadingAnchorConstraint
    self.text1ViewTrailingAnchorConstraint = text1ViewTrailingAnchorConstraint
    self.text2ViewTopAnchorConstraint = text2ViewTopAnchorConstraint
    self.text2ViewLeadingAnchorConstraint = text2ViewLeadingAnchorConstraint
    self.text2ViewTrailingAnchorConstraint = text2ViewTrailingAnchorConstraint
    self.text3ViewTopAnchorConstraint = text3ViewTopAnchorConstraint
    self.text3ViewLeadingAnchorConstraint = text3ViewLeadingAnchorConstraint
    self.text3ViewTrailingAnchorConstraint = text3ViewTrailingAnchorConstraint
    self.text4ViewTopAnchorConstraint = text4ViewTopAnchorConstraint
    self.text4ViewLeadingAnchorConstraint = text4ViewLeadingAnchorConstraint
    self.text4ViewTrailingAnchorConstraint = text4ViewTrailingAnchorConstraint
    self.text5ViewTopAnchorConstraint = text5ViewTopAnchorConstraint
    self.text5ViewLeadingAnchorConstraint = text5ViewLeadingAnchorConstraint
    self.text5ViewTrailingAnchorConstraint = text5ViewTrailingAnchorConstraint
    self.text6ViewTopAnchorConstraint = text6ViewTopAnchorConstraint
    self.text6ViewLeadingAnchorConstraint = text6ViewLeadingAnchorConstraint
    self.text6ViewTrailingAnchorConstraint = text6ViewTrailingAnchorConstraint
    self.text7ViewTopAnchorConstraint = text7ViewTopAnchorConstraint
    self.text7ViewLeadingAnchorConstraint = text7ViewLeadingAnchorConstraint
    self.text7ViewTrailingAnchorConstraint = text7ViewTrailingAnchorConstraint
    self.text8ViewTopAnchorConstraint = text8ViewTopAnchorConstraint
    self.text8ViewLeadingAnchorConstraint = text8ViewLeadingAnchorConstraint
    self.text8ViewTrailingAnchorConstraint = text8ViewTrailingAnchorConstraint
    self.text9ViewBottomAnchorConstraint = text9ViewBottomAnchorConstraint
    self.text9ViewTopAnchorConstraint = text9ViewTopAnchorConstraint
    self.text9ViewLeadingAnchorConstraint = text9ViewLeadingAnchorConstraint
    self.text9ViewTrailingAnchorConstraint = text9ViewTrailingAnchorConstraint

    // For debugging
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    text1ViewTopAnchorConstraint.identifier = "text1ViewTopAnchorConstraint"
    text1ViewLeadingAnchorConstraint.identifier = "text1ViewLeadingAnchorConstraint"
    text1ViewTrailingAnchorConstraint.identifier = "text1ViewTrailingAnchorConstraint"
    text2ViewTopAnchorConstraint.identifier = "text2ViewTopAnchorConstraint"
    text2ViewLeadingAnchorConstraint.identifier = "text2ViewLeadingAnchorConstraint"
    text2ViewTrailingAnchorConstraint.identifier = "text2ViewTrailingAnchorConstraint"
    text3ViewTopAnchorConstraint.identifier = "text3ViewTopAnchorConstraint"
    text3ViewLeadingAnchorConstraint.identifier = "text3ViewLeadingAnchorConstraint"
    text3ViewTrailingAnchorConstraint.identifier = "text3ViewTrailingAnchorConstraint"
    text4ViewTopAnchorConstraint.identifier = "text4ViewTopAnchorConstraint"
    text4ViewLeadingAnchorConstraint.identifier = "text4ViewLeadingAnchorConstraint"
    text4ViewTrailingAnchorConstraint.identifier = "text4ViewTrailingAnchorConstraint"
    text5ViewTopAnchorConstraint.identifier = "text5ViewTopAnchorConstraint"
    text5ViewLeadingAnchorConstraint.identifier = "text5ViewLeadingAnchorConstraint"
    text5ViewTrailingAnchorConstraint.identifier = "text5ViewTrailingAnchorConstraint"
    text6ViewTopAnchorConstraint.identifier = "text6ViewTopAnchorConstraint"
    text6ViewLeadingAnchorConstraint.identifier = "text6ViewLeadingAnchorConstraint"
    text6ViewTrailingAnchorConstraint.identifier = "text6ViewTrailingAnchorConstraint"
    text7ViewTopAnchorConstraint.identifier = "text7ViewTopAnchorConstraint"
    text7ViewLeadingAnchorConstraint.identifier = "text7ViewLeadingAnchorConstraint"
    text7ViewTrailingAnchorConstraint.identifier = "text7ViewTrailingAnchorConstraint"
    text8ViewTopAnchorConstraint.identifier = "text8ViewTopAnchorConstraint"
    text8ViewLeadingAnchorConstraint.identifier = "text8ViewLeadingAnchorConstraint"
    text8ViewTrailingAnchorConstraint.identifier = "text8ViewTrailingAnchorConstraint"
    text9ViewBottomAnchorConstraint.identifier = "text9ViewBottomAnchorConstraint"
    text9ViewTopAnchorConstraint.identifier = "text9ViewTopAnchorConstraint"
    text9ViewLeadingAnchorConstraint.identifier = "text9ViewLeadingAnchorConstraint"
    text9ViewTrailingAnchorConstraint.identifier = "text9ViewTrailingAnchorConstraint"
  }

  private func update() {}
}
