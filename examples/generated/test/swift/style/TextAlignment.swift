import UIKit
import Foundation

// MARK: - TextAlignment

public class TextAlignment: UIView {

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

  private var view1View = UIView(frame: .zero)
  private var imageView = UIImageView(frame: .zero)
  private var view2View = UIView(frame: .zero)
  private var textView = UILabel()
  private var text1View = UILabel()
  private var text2View = UILabel()
  private var text3View = UILabel()
  private var text4View = UILabel()
  private var view3View = UIView(frame: .zero)
  private var text5View = UILabel()
  private var view4View = UIView(frame: .zero)
  private var text6View = UILabel()
  private var view5View = UIView(frame: .zero)
  private var text7View = UILabel()
  private var view6View = UIView(frame: .zero)
  private var text8View = UILabel()
  private var rightAlignmentContainerView = UIView(frame: .zero)
  private var text9View = UILabel()
  private var text10View = UILabel()
  private var image1View = UIImageView(frame: .zero)

  private var textViewTextStyle = TextStyles.display1.with(alignment: .center)
  private var text1ViewTextStyle = TextStyles.subheading2.with(alignment: .center)
  private var text2ViewTextStyle = TextStyles.body1
  private var text3ViewTextStyle = TextStyles.body1.with(alignment: .right)
  private var text4ViewTextStyle = TextStyles.body1.with(alignment: .center)
  private var text5ViewTextStyle = TextStyles.body1
  private var text6ViewTextStyle = TextStyles.body1
  private var text7ViewTextStyle = TextStyles.body1.with(alignment: .center)
  private var text8ViewTextStyle = TextStyles.body1.with(alignment: .center)
  private var text9ViewTextStyle = TextStyles.body1
  private var text10ViewTextStyle = TextStyles.body1.with(alignment: .center)

  private var topPadding: CGFloat = 10
  private var trailingPadding: CGFloat = 10
  private var bottomPadding: CGFloat = 10
  private var leadingPadding: CGFloat = 10
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0
  private var view1ViewTopPadding: CGFloat = 0
  private var view1ViewTrailingPadding: CGFloat = 0
  private var view1ViewBottomPadding: CGFloat = 0
  private var view1ViewLeadingPadding: CGFloat = 0
  private var view3ViewTopMargin: CGFloat = 0
  private var view3ViewTrailingMargin: CGFloat = 0
  private var view3ViewBottomMargin: CGFloat = 0
  private var view3ViewLeadingMargin: CGFloat = 0
  private var view3ViewTopPadding: CGFloat = 0
  private var view3ViewTrailingPadding: CGFloat = 12
  private var view3ViewBottomPadding: CGFloat = 0
  private var view3ViewLeadingPadding: CGFloat = 12
  private var view4ViewTopMargin: CGFloat = 0
  private var view4ViewTrailingMargin: CGFloat = 0
  private var view4ViewBottomMargin: CGFloat = 0
  private var view4ViewLeadingMargin: CGFloat = 0
  private var view4ViewTopPadding: CGFloat = 0
  private var view4ViewTrailingPadding: CGFloat = 12
  private var view4ViewBottomPadding: CGFloat = 0
  private var view4ViewLeadingPadding: CGFloat = 12
  private var view5ViewTopMargin: CGFloat = 0
  private var view5ViewTrailingMargin: CGFloat = 0
  private var view5ViewBottomMargin: CGFloat = 0
  private var view5ViewLeadingMargin: CGFloat = 0
  private var view5ViewTopPadding: CGFloat = 0
  private var view5ViewTrailingPadding: CGFloat = 12
  private var view5ViewBottomPadding: CGFloat = 0
  private var view5ViewLeadingPadding: CGFloat = 12
  private var view6ViewTopMargin: CGFloat = 0
  private var view6ViewTrailingMargin: CGFloat = 0
  private var view6ViewBottomMargin: CGFloat = 0
  private var view6ViewLeadingMargin: CGFloat = 0
  private var view6ViewTopPadding: CGFloat = 0
  private var view6ViewTrailingPadding: CGFloat = 12
  private var view6ViewBottomPadding: CGFloat = 0
  private var view6ViewLeadingPadding: CGFloat = 12
  private var rightAlignmentContainerViewTopMargin: CGFloat = 0
  private var rightAlignmentContainerViewTrailingMargin: CGFloat = 0
  private var rightAlignmentContainerViewBottomMargin: CGFloat = 0
  private var rightAlignmentContainerViewLeadingMargin: CGFloat = 0
  private var rightAlignmentContainerViewTopPadding: CGFloat = 0
  private var rightAlignmentContainerViewTrailingPadding: CGFloat = 0
  private var rightAlignmentContainerViewBottomPadding: CGFloat = 0
  private var rightAlignmentContainerViewLeadingPadding: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 0
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0
  private var view2ViewTopMargin: CGFloat = 0
  private var view2ViewTrailingMargin: CGFloat = 0
  private var view2ViewBottomMargin: CGFloat = 0
  private var view2ViewLeadingMargin: CGFloat = 0
  private var textViewTopMargin: CGFloat = 16
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0
  private var text1ViewTopMargin: CGFloat = 16
  private var text1ViewTrailingMargin: CGFloat = 0
  private var text1ViewBottomMargin: CGFloat = 0
  private var text1ViewLeadingMargin: CGFloat = 0
  private var text2ViewTopMargin: CGFloat = 12
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
  private var text10ViewTopMargin: CGFloat = 0
  private var text10ViewTrailingMargin: CGFloat = 0
  private var text10ViewBottomMargin: CGFloat = 0
  private var text10ViewLeadingMargin: CGFloat = 0
  private var image1ViewTopMargin: CGFloat = 0
  private var image1ViewTrailingMargin: CGFloat = 0
  private var image1ViewBottomMargin: CGFloat = 0
  private var image1ViewLeadingMargin: CGFloat = 0

  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view3ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view4ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view4ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view5ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view5ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view5ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view6ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view6ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var rightAlignmentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var rightAlignmentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var rightAlignmentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var rightAlignmentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text3ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text3ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text4ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text4ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text4ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text5ViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var text5ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text5ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text5ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text5ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text5ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view4ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var text6ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text6ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text6ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text6ViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var text6ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text7ViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var text7ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text7ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text7ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text7ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view6ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var text8ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text8ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text8ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text8ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text9ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text9ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text9ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text10ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text10ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text10ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var image1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var image1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var image1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?
  private var text4ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var image1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var image1ViewWidthAnchorConstraint: NSLayoutConstraint?

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
    text10View.numberOfLines = 0

    addSubview(view1View)
    addSubview(view3View)
    addSubview(view4View)
    addSubview(view5View)
    addSubview(view6View)
    addSubview(rightAlignmentContainerView)
    view1View.addSubview(imageView)
    view1View.addSubview(view2View)
    view1View.addSubview(textView)
    view1View.addSubview(text1View)
    view1View.addSubview(text2View)
    view1View.addSubview(text3View)
    view1View.addSubview(text4View)
    view3View.addSubview(text5View)
    view4View.addSubview(text6View)
    view5View.addSubview(text7View)
    view6View.addSubview(text8View)
    rightAlignmentContainerView.addSubview(text9View)
    rightAlignmentContainerView.addSubview(text10View)
    rightAlignmentContainerView.addSubview(image1View)

    view1View.backgroundColor = Colors.indigo50
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    view2View.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textViewTextStyle = TextStyles.display1.with(alignment: .center)
    textView.attributedText = textViewTextStyle.apply(to: "Welcome to Lona Studio")
    text1ViewTextStyle = TextStyles.subheading2.with(alignment: .center)
    text1View.attributedText = text1ViewTextStyle.apply(to: "Centered - Width: Fit")
    text2View.attributedText = text2ViewTextStyle.apply(to: "Left aligned - Width: Fill")
    text3View.attributedText = text3ViewTextStyle.apply(to: "Right aligned - Width: Fill")
    text4View.attributedText = text4ViewTextStyle.apply(to: "Centered - Width: 80")
    view3View.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text5View.attributedText = text5ViewTextStyle.apply(to: "Left aligned text, Fit w/ secondary centering")
    view4View.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text6View.attributedText = text6ViewTextStyle.apply(to: "Left aligned text, Fixed w/ secondary centering")
    view5View.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text7View.attributedText = text7ViewTextStyle.apply(to: "Centered text, Fit parent no centering")
    view6View.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text8View.attributedText = text8ViewTextStyle.apply(to: "Centered text, Fixed parent no centering")
    rightAlignmentContainerView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text9View.attributedText = text9ViewTextStyle.apply(to: "Fit Text")
    text10View.attributedText = text10ViewTextStyle.apply(to: "Fill and center aligned text")
    image1View.image = #imageLiteral(resourceName: "icon_128x128")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    view5View.translatesAutoresizingMaskIntoConstraints = false
    view6View.translatesAutoresizingMaskIntoConstraints = false
    rightAlignmentContainerView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
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
    text10View.translatesAutoresizingMaskIntoConstraints = false
    image1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTrailingAnchorConstraint = view1View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view1ViewTrailingMargin))
    let view3ViewTopAnchorConstraint = view3View
      .topAnchor
      .constraint(equalTo: view1View.bottomAnchor, constant: view1ViewBottomMargin + view3ViewTopMargin)
    let view3ViewLeadingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view3ViewLeadingMargin)
    let view3ViewTrailingAnchorConstraint = view3View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + view3ViewTrailingMargin))
    let view4ViewTopAnchorConstraint = view4View
      .topAnchor
      .constraint(equalTo: view3View.bottomAnchor, constant: view3ViewBottomMargin + view4ViewTopMargin)
    let view4ViewLeadingAnchorConstraint = view4View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view4ViewLeadingMargin)
    let view5ViewTopAnchorConstraint = view5View
      .topAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: view4ViewBottomMargin + view5ViewTopMargin)
    let view5ViewLeadingAnchorConstraint = view5View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view5ViewLeadingMargin)
    let view5ViewTrailingAnchorConstraint = view5View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + view5ViewTrailingMargin))
    let view6ViewTopAnchorConstraint = view6View
      .topAnchor
      .constraint(equalTo: view5View.bottomAnchor, constant: view5ViewBottomMargin + view6ViewTopMargin)
    let view6ViewLeadingAnchorConstraint = view6View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view6ViewLeadingMargin)
    let rightAlignmentContainerViewBottomAnchorConstraint = rightAlignmentContainerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + rightAlignmentContainerViewBottomMargin))
    let rightAlignmentContainerViewTopAnchorConstraint = rightAlignmentContainerView
      .topAnchor
      .constraint(
        equalTo: view6View.bottomAnchor,
        constant: view6ViewBottomMargin + rightAlignmentContainerViewTopMargin)
    let rightAlignmentContainerViewLeadingAnchorConstraint = rightAlignmentContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + rightAlignmentContainerViewLeadingMargin)
    let rightAlignmentContainerViewTrailingAnchorConstraint = rightAlignmentContainerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + rightAlignmentContainerViewTrailingMargin))
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor, constant: view1ViewTopPadding + imageViewTopMargin)
    let imageViewCenterXAnchorConstraint = imageView
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let view2ViewTopAnchorConstraint = view2View
      .topAnchor
      .constraint(equalTo: imageView.bottomAnchor, constant: imageViewBottomMargin + view2ViewTopMargin)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(
        greaterThanOrEqualTo: view1View.leadingAnchor,
        constant: view1ViewLeadingPadding + view2ViewLeadingMargin)
    let view2ViewCenterXAnchorConstraint = view2View
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let view2ViewTrailingAnchorConstraint = view2View
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: view1View.trailingAnchor,
        constant: -(view1ViewTrailingPadding + view2ViewTrailingMargin))
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: view2View.bottomAnchor, constant: view2ViewBottomMargin + textViewTopMargin)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + textViewLeadingMargin)
    let textViewCenterXAnchorConstraint = textView
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: -(view1ViewTrailingPadding + textViewTrailingMargin))
    let text1ViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(equalTo: textView.bottomAnchor, constant: textViewBottomMargin + text1ViewTopMargin)
    let text1ViewLeadingAnchorConstraint = text1View
      .leadingAnchor
      .constraint(
        greaterThanOrEqualTo: view1View.leadingAnchor,
        constant: view1ViewLeadingPadding + text1ViewLeadingMargin)
    let text1ViewCenterXAnchorConstraint = text1View
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: view1View.trailingAnchor,
        constant: -(view1ViewTrailingPadding + text1ViewTrailingMargin))
    let text2ViewTopAnchorConstraint = text2View
      .topAnchor
      .constraint(equalTo: text1View.bottomAnchor, constant: text1ViewBottomMargin + text2ViewTopMargin)
    let text2ViewLeadingAnchorConstraint = text2View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + text2ViewLeadingMargin)
    let text2ViewCenterXAnchorConstraint = text2View
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let text2ViewTrailingAnchorConstraint = text2View
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: -(view1ViewTrailingPadding + text2ViewTrailingMargin))
    let text3ViewTopAnchorConstraint = text3View
      .topAnchor
      .constraint(equalTo: text2View.bottomAnchor, constant: text2ViewBottomMargin + text3ViewTopMargin)
    let text3ViewLeadingAnchorConstraint = text3View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + text3ViewLeadingMargin)
    let text3ViewCenterXAnchorConstraint = text3View
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let text3ViewTrailingAnchorConstraint = text3View
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: -(view1ViewTrailingPadding + text3ViewTrailingMargin))
    let text4ViewBottomAnchorConstraint = text4View
      .bottomAnchor
      .constraint(equalTo: view1View.bottomAnchor, constant: -(view1ViewBottomPadding + text4ViewBottomMargin))
    let text4ViewTopAnchorConstraint = text4View
      .topAnchor
      .constraint(equalTo: text3View.bottomAnchor, constant: text3ViewBottomMargin + text4ViewTopMargin)
    let text4ViewCenterXAnchorConstraint = text4View
      .centerXAnchor
      .constraint(equalTo: view1View.centerXAnchor, constant: 0)
    let text5ViewWidthAnchorParentConstraint = text5View
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: view3View.widthAnchor,
        constant:
        -(view3ViewLeadingPadding + text5ViewLeadingMargin + view3ViewTrailingPadding + text5ViewTrailingMargin))
    let text5ViewTopAnchorConstraint = text5View
      .topAnchor
      .constraint(equalTo: view3View.topAnchor, constant: view3ViewTopPadding + text5ViewTopMargin)
    let text5ViewBottomAnchorConstraint = text5View
      .bottomAnchor
      .constraint(equalTo: view3View.bottomAnchor, constant: -(view3ViewBottomPadding + text5ViewBottomMargin))
    let text5ViewLeadingAnchorConstraint = text5View
      .leadingAnchor
      .constraint(equalTo: view3View.leadingAnchor, constant: view3ViewLeadingPadding + text5ViewLeadingMargin)
    let text5ViewCenterXAnchorConstraint = text5View
      .centerXAnchor
      .constraint(equalTo: view3View.centerXAnchor, constant: 0)
    let text5ViewTrailingAnchorConstraint = text5View
      .trailingAnchor
      .constraint(equalTo: view3View.trailingAnchor, constant: -(view3ViewTrailingPadding + text5ViewTrailingMargin))
    let view4ViewWidthAnchorConstraint = view4View.widthAnchor.constraint(equalToConstant: 400)
    let text6ViewTopAnchorConstraint = text6View
      .topAnchor
      .constraint(equalTo: view4View.topAnchor, constant: view4ViewTopPadding + text6ViewTopMargin)
    let text6ViewBottomAnchorConstraint = text6View
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -(view4ViewBottomPadding + text6ViewBottomMargin))
    let text6ViewLeadingAnchorConstraint = text6View
      .leadingAnchor
      .constraint(equalTo: view4View.leadingAnchor, constant: view4ViewLeadingPadding + text6ViewLeadingMargin)
    let text6ViewCenterXAnchorConstraint = text6View
      .centerXAnchor
      .constraint(equalTo: view4View.centerXAnchor, constant: 0)
    let text6ViewTrailingAnchorConstraint = text6View
      .trailingAnchor
      .constraint(equalTo: view4View.trailingAnchor, constant: -(view4ViewTrailingPadding + text6ViewTrailingMargin))
    let text7ViewWidthAnchorParentConstraint = text7View
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: view5View.widthAnchor,
        constant:
        -(view5ViewLeadingPadding + text7ViewLeadingMargin + view5ViewTrailingPadding + text7ViewTrailingMargin))
    let text7ViewTopAnchorConstraint = text7View
      .topAnchor
      .constraint(equalTo: view5View.topAnchor, constant: view5ViewTopPadding + text7ViewTopMargin)
    let text7ViewBottomAnchorConstraint = text7View
      .bottomAnchor
      .constraint(equalTo: view5View.bottomAnchor, constant: -(view5ViewBottomPadding + text7ViewBottomMargin))
    let text7ViewLeadingAnchorConstraint = text7View
      .leadingAnchor
      .constraint(equalTo: view5View.leadingAnchor, constant: view5ViewLeadingPadding + text7ViewLeadingMargin)
    let text7ViewTrailingAnchorConstraint = text7View
      .trailingAnchor
      .constraint(equalTo: view5View.trailingAnchor, constant: -(view5ViewTrailingPadding + text7ViewTrailingMargin))
    let view6ViewWidthAnchorConstraint = view6View.widthAnchor.constraint(equalToConstant: 400)
    let text8ViewTopAnchorConstraint = text8View
      .topAnchor
      .constraint(equalTo: view6View.topAnchor, constant: view6ViewTopPadding + text8ViewTopMargin)
    let text8ViewBottomAnchorConstraint = text8View
      .bottomAnchor
      .constraint(equalTo: view6View.bottomAnchor, constant: -(view6ViewBottomPadding + text8ViewBottomMargin))
    let text8ViewLeadingAnchorConstraint = text8View
      .leadingAnchor
      .constraint(equalTo: view6View.leadingAnchor, constant: view6ViewLeadingPadding + text8ViewLeadingMargin)
    let text8ViewTrailingAnchorConstraint = text8View
      .trailingAnchor
      .constraint(equalTo: view6View.trailingAnchor, constant: -(view6ViewTrailingPadding + text8ViewTrailingMargin))
    let text9ViewTopAnchorConstraint = text9View
      .topAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.topAnchor,
        constant: rightAlignmentContainerViewTopPadding + text9ViewTopMargin)
    let text9ViewLeadingAnchorConstraint = text9View
      .leadingAnchor
      .constraint(
        greaterThanOrEqualTo: rightAlignmentContainerView.leadingAnchor,
        constant: rightAlignmentContainerViewLeadingPadding + text9ViewLeadingMargin)
    let text9ViewTrailingAnchorConstraint = text9View
      .trailingAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.trailingAnchor,
        constant: -(rightAlignmentContainerViewTrailingPadding + text9ViewTrailingMargin))
    let text10ViewTopAnchorConstraint = text10View
      .topAnchor
      .constraint(equalTo: text9View.bottomAnchor, constant: text9ViewBottomMargin + text10ViewTopMargin)
    let text10ViewLeadingAnchorConstraint = text10View
      .leadingAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.leadingAnchor,
        constant: rightAlignmentContainerViewLeadingPadding + text10ViewLeadingMargin)
    let text10ViewTrailingAnchorConstraint = text10View
      .trailingAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.trailingAnchor,
        constant: -(rightAlignmentContainerViewTrailingPadding + text10ViewTrailingMargin))
    let image1ViewBottomAnchorConstraint = image1View
      .bottomAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.bottomAnchor,
        constant: -(rightAlignmentContainerViewBottomPadding + image1ViewBottomMargin))
    let image1ViewTopAnchorConstraint = image1View
      .topAnchor
      .constraint(equalTo: text10View.bottomAnchor, constant: text10ViewBottomMargin + image1ViewTopMargin)
    let image1ViewTrailingAnchorConstraint = image1View
      .trailingAnchor
      .constraint(
        equalTo: rightAlignmentContainerView.trailingAnchor,
        constant: -(rightAlignmentContainerViewTrailingPadding + image1ViewTrailingMargin))
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)
    let text4ViewWidthAnchorConstraint = text4View.widthAnchor.constraint(equalToConstant: 80)
    let image1ViewHeightAnchorConstraint = image1View.heightAnchor.constraint(equalToConstant: 100)
    let image1ViewWidthAnchorConstraint = image1View.widthAnchor.constraint(equalToConstant: 100)

    text5ViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    text7ViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTrailingAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view5ViewTopAnchorConstraint,
      view5ViewLeadingAnchorConstraint,
      view5ViewTrailingAnchorConstraint,
      view6ViewTopAnchorConstraint,
      view6ViewLeadingAnchorConstraint,
      rightAlignmentContainerViewBottomAnchorConstraint,
      rightAlignmentContainerViewTopAnchorConstraint,
      rightAlignmentContainerViewLeadingAnchorConstraint,
      rightAlignmentContainerViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewCenterXAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewCenterXAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewCenterXAnchorConstraint,
      textViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewCenterXAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      text2ViewTopAnchorConstraint,
      text2ViewLeadingAnchorConstraint,
      text2ViewCenterXAnchorConstraint,
      text2ViewTrailingAnchorConstraint,
      text3ViewTopAnchorConstraint,
      text3ViewLeadingAnchorConstraint,
      text3ViewCenterXAnchorConstraint,
      text3ViewTrailingAnchorConstraint,
      text4ViewBottomAnchorConstraint,
      text4ViewTopAnchorConstraint,
      text4ViewCenterXAnchorConstraint,
      text5ViewWidthAnchorParentConstraint,
      text5ViewTopAnchorConstraint,
      text5ViewBottomAnchorConstraint,
      text5ViewLeadingAnchorConstraint,
      text5ViewCenterXAnchorConstraint,
      text5ViewTrailingAnchorConstraint,
      view4ViewWidthAnchorConstraint,
      text6ViewTopAnchorConstraint,
      text6ViewBottomAnchorConstraint,
      text6ViewLeadingAnchorConstraint,
      text6ViewCenterXAnchorConstraint,
      text6ViewTrailingAnchorConstraint,
      text7ViewWidthAnchorParentConstraint,
      text7ViewTopAnchorConstraint,
      text7ViewBottomAnchorConstraint,
      text7ViewLeadingAnchorConstraint,
      text7ViewTrailingAnchorConstraint,
      view6ViewWidthAnchorConstraint,
      text8ViewTopAnchorConstraint,
      text8ViewBottomAnchorConstraint,
      text8ViewLeadingAnchorConstraint,
      text8ViewTrailingAnchorConstraint,
      text9ViewTopAnchorConstraint,
      text9ViewLeadingAnchorConstraint,
      text9ViewTrailingAnchorConstraint,
      text10ViewTopAnchorConstraint,
      text10ViewLeadingAnchorConstraint,
      text10ViewTrailingAnchorConstraint,
      image1ViewBottomAnchorConstraint,
      image1ViewTopAnchorConstraint,
      image1ViewTrailingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint,
      text4ViewWidthAnchorConstraint,
      image1ViewHeightAnchorConstraint,
      image1ViewWidthAnchorConstraint
    ])

    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTrailingAnchorConstraint = view1ViewTrailingAnchorConstraint
    self.view3ViewTopAnchorConstraint = view3ViewTopAnchorConstraint
    self.view3ViewLeadingAnchorConstraint = view3ViewLeadingAnchorConstraint
    self.view3ViewTrailingAnchorConstraint = view3ViewTrailingAnchorConstraint
    self.view4ViewTopAnchorConstraint = view4ViewTopAnchorConstraint
    self.view4ViewLeadingAnchorConstraint = view4ViewLeadingAnchorConstraint
    self.view5ViewTopAnchorConstraint = view5ViewTopAnchorConstraint
    self.view5ViewLeadingAnchorConstraint = view5ViewLeadingAnchorConstraint
    self.view5ViewTrailingAnchorConstraint = view5ViewTrailingAnchorConstraint
    self.view6ViewTopAnchorConstraint = view6ViewTopAnchorConstraint
    self.view6ViewLeadingAnchorConstraint = view6ViewLeadingAnchorConstraint
    self.rightAlignmentContainerViewBottomAnchorConstraint = rightAlignmentContainerViewBottomAnchorConstraint
    self.rightAlignmentContainerViewTopAnchorConstraint = rightAlignmentContainerViewTopAnchorConstraint
    self.rightAlignmentContainerViewLeadingAnchorConstraint = rightAlignmentContainerViewLeadingAnchorConstraint
    self.rightAlignmentContainerViewTrailingAnchorConstraint = rightAlignmentContainerViewTrailingAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewCenterXAnchorConstraint = imageViewCenterXAnchorConstraint
    self.view2ViewTopAnchorConstraint = view2ViewTopAnchorConstraint
    self.view2ViewLeadingAnchorConstraint = view2ViewLeadingAnchorConstraint
    self.view2ViewCenterXAnchorConstraint = view2ViewCenterXAnchorConstraint
    self.view2ViewTrailingAnchorConstraint = view2ViewTrailingAnchorConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewCenterXAnchorConstraint = textViewCenterXAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.text1ViewTopAnchorConstraint = text1ViewTopAnchorConstraint
    self.text1ViewLeadingAnchorConstraint = text1ViewLeadingAnchorConstraint
    self.text1ViewCenterXAnchorConstraint = text1ViewCenterXAnchorConstraint
    self.text1ViewTrailingAnchorConstraint = text1ViewTrailingAnchorConstraint
    self.text2ViewTopAnchorConstraint = text2ViewTopAnchorConstraint
    self.text2ViewLeadingAnchorConstraint = text2ViewLeadingAnchorConstraint
    self.text2ViewCenterXAnchorConstraint = text2ViewCenterXAnchorConstraint
    self.text2ViewTrailingAnchorConstraint = text2ViewTrailingAnchorConstraint
    self.text3ViewTopAnchorConstraint = text3ViewTopAnchorConstraint
    self.text3ViewLeadingAnchorConstraint = text3ViewLeadingAnchorConstraint
    self.text3ViewCenterXAnchorConstraint = text3ViewCenterXAnchorConstraint
    self.text3ViewTrailingAnchorConstraint = text3ViewTrailingAnchorConstraint
    self.text4ViewBottomAnchorConstraint = text4ViewBottomAnchorConstraint
    self.text4ViewTopAnchorConstraint = text4ViewTopAnchorConstraint
    self.text4ViewCenterXAnchorConstraint = text4ViewCenterXAnchorConstraint
    self.text5ViewWidthAnchorParentConstraint = text5ViewWidthAnchorParentConstraint
    self.text5ViewTopAnchorConstraint = text5ViewTopAnchorConstraint
    self.text5ViewBottomAnchorConstraint = text5ViewBottomAnchorConstraint
    self.text5ViewLeadingAnchorConstraint = text5ViewLeadingAnchorConstraint
    self.text5ViewCenterXAnchorConstraint = text5ViewCenterXAnchorConstraint
    self.text5ViewTrailingAnchorConstraint = text5ViewTrailingAnchorConstraint
    self.view4ViewWidthAnchorConstraint = view4ViewWidthAnchorConstraint
    self.text6ViewTopAnchorConstraint = text6ViewTopAnchorConstraint
    self.text6ViewBottomAnchorConstraint = text6ViewBottomAnchorConstraint
    self.text6ViewLeadingAnchorConstraint = text6ViewLeadingAnchorConstraint
    self.text6ViewCenterXAnchorConstraint = text6ViewCenterXAnchorConstraint
    self.text6ViewTrailingAnchorConstraint = text6ViewTrailingAnchorConstraint
    self.text7ViewWidthAnchorParentConstraint = text7ViewWidthAnchorParentConstraint
    self.text7ViewTopAnchorConstraint = text7ViewTopAnchorConstraint
    self.text7ViewBottomAnchorConstraint = text7ViewBottomAnchorConstraint
    self.text7ViewLeadingAnchorConstraint = text7ViewLeadingAnchorConstraint
    self.text7ViewTrailingAnchorConstraint = text7ViewTrailingAnchorConstraint
    self.view6ViewWidthAnchorConstraint = view6ViewWidthAnchorConstraint
    self.text8ViewTopAnchorConstraint = text8ViewTopAnchorConstraint
    self.text8ViewBottomAnchorConstraint = text8ViewBottomAnchorConstraint
    self.text8ViewLeadingAnchorConstraint = text8ViewLeadingAnchorConstraint
    self.text8ViewTrailingAnchorConstraint = text8ViewTrailingAnchorConstraint
    self.text9ViewTopAnchorConstraint = text9ViewTopAnchorConstraint
    self.text9ViewLeadingAnchorConstraint = text9ViewLeadingAnchorConstraint
    self.text9ViewTrailingAnchorConstraint = text9ViewTrailingAnchorConstraint
    self.text10ViewTopAnchorConstraint = text10ViewTopAnchorConstraint
    self.text10ViewLeadingAnchorConstraint = text10ViewLeadingAnchorConstraint
    self.text10ViewTrailingAnchorConstraint = text10ViewTrailingAnchorConstraint
    self.image1ViewBottomAnchorConstraint = image1ViewBottomAnchorConstraint
    self.image1ViewTopAnchorConstraint = image1ViewTopAnchorConstraint
    self.image1ViewTrailingAnchorConstraint = image1ViewTrailingAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint
    self.text4ViewWidthAnchorConstraint = text4ViewWidthAnchorConstraint
    self.image1ViewHeightAnchorConstraint = image1ViewHeightAnchorConstraint
    self.image1ViewWidthAnchorConstraint = image1ViewWidthAnchorConstraint

    // For debugging
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTrailingAnchorConstraint.identifier = "view1ViewTrailingAnchorConstraint"
    view3ViewTopAnchorConstraint.identifier = "view3ViewTopAnchorConstraint"
    view3ViewLeadingAnchorConstraint.identifier = "view3ViewLeadingAnchorConstraint"
    view3ViewTrailingAnchorConstraint.identifier = "view3ViewTrailingAnchorConstraint"
    view4ViewTopAnchorConstraint.identifier = "view4ViewTopAnchorConstraint"
    view4ViewLeadingAnchorConstraint.identifier = "view4ViewLeadingAnchorConstraint"
    view5ViewTopAnchorConstraint.identifier = "view5ViewTopAnchorConstraint"
    view5ViewLeadingAnchorConstraint.identifier = "view5ViewLeadingAnchorConstraint"
    view5ViewTrailingAnchorConstraint.identifier = "view5ViewTrailingAnchorConstraint"
    view6ViewTopAnchorConstraint.identifier = "view6ViewTopAnchorConstraint"
    view6ViewLeadingAnchorConstraint.identifier = "view6ViewLeadingAnchorConstraint"
    rightAlignmentContainerViewBottomAnchorConstraint.identifier = "rightAlignmentContainerViewBottomAnchorConstraint"
    rightAlignmentContainerViewTopAnchorConstraint.identifier = "rightAlignmentContainerViewTopAnchorConstraint"
    rightAlignmentContainerViewLeadingAnchorConstraint.identifier = "rightAlignmentContainerViewLeadingAnchorConstraint"
    rightAlignmentContainerViewTrailingAnchorConstraint.identifier =
      "rightAlignmentContainerViewTrailingAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewCenterXAnchorConstraint.identifier = "imageViewCenterXAnchorConstraint"
    view2ViewTopAnchorConstraint.identifier = "view2ViewTopAnchorConstraint"
    view2ViewLeadingAnchorConstraint.identifier = "view2ViewLeadingAnchorConstraint"
    view2ViewCenterXAnchorConstraint.identifier = "view2ViewCenterXAnchorConstraint"
    view2ViewTrailingAnchorConstraint.identifier = "view2ViewTrailingAnchorConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewCenterXAnchorConstraint.identifier = "textViewCenterXAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    text1ViewTopAnchorConstraint.identifier = "text1ViewTopAnchorConstraint"
    text1ViewLeadingAnchorConstraint.identifier = "text1ViewLeadingAnchorConstraint"
    text1ViewCenterXAnchorConstraint.identifier = "text1ViewCenterXAnchorConstraint"
    text1ViewTrailingAnchorConstraint.identifier = "text1ViewTrailingAnchorConstraint"
    text2ViewTopAnchorConstraint.identifier = "text2ViewTopAnchorConstraint"
    text2ViewLeadingAnchorConstraint.identifier = "text2ViewLeadingAnchorConstraint"
    text2ViewCenterXAnchorConstraint.identifier = "text2ViewCenterXAnchorConstraint"
    text2ViewTrailingAnchorConstraint.identifier = "text2ViewTrailingAnchorConstraint"
    text3ViewTopAnchorConstraint.identifier = "text3ViewTopAnchorConstraint"
    text3ViewLeadingAnchorConstraint.identifier = "text3ViewLeadingAnchorConstraint"
    text3ViewCenterXAnchorConstraint.identifier = "text3ViewCenterXAnchorConstraint"
    text3ViewTrailingAnchorConstraint.identifier = "text3ViewTrailingAnchorConstraint"
    text4ViewBottomAnchorConstraint.identifier = "text4ViewBottomAnchorConstraint"
    text4ViewTopAnchorConstraint.identifier = "text4ViewTopAnchorConstraint"
    text4ViewCenterXAnchorConstraint.identifier = "text4ViewCenterXAnchorConstraint"
    text5ViewWidthAnchorParentConstraint.identifier = "text5ViewWidthAnchorParentConstraint"
    text5ViewTopAnchorConstraint.identifier = "text5ViewTopAnchorConstraint"
    text5ViewBottomAnchorConstraint.identifier = "text5ViewBottomAnchorConstraint"
    text5ViewLeadingAnchorConstraint.identifier = "text5ViewLeadingAnchorConstraint"
    text5ViewCenterXAnchorConstraint.identifier = "text5ViewCenterXAnchorConstraint"
    text5ViewTrailingAnchorConstraint.identifier = "text5ViewTrailingAnchorConstraint"
    view4ViewWidthAnchorConstraint.identifier = "view4ViewWidthAnchorConstraint"
    text6ViewTopAnchorConstraint.identifier = "text6ViewTopAnchorConstraint"
    text6ViewBottomAnchorConstraint.identifier = "text6ViewBottomAnchorConstraint"
    text6ViewLeadingAnchorConstraint.identifier = "text6ViewLeadingAnchorConstraint"
    text6ViewCenterXAnchorConstraint.identifier = "text6ViewCenterXAnchorConstraint"
    text6ViewTrailingAnchorConstraint.identifier = "text6ViewTrailingAnchorConstraint"
    text7ViewWidthAnchorParentConstraint.identifier = "text7ViewWidthAnchorParentConstraint"
    text7ViewTopAnchorConstraint.identifier = "text7ViewTopAnchorConstraint"
    text7ViewBottomAnchorConstraint.identifier = "text7ViewBottomAnchorConstraint"
    text7ViewLeadingAnchorConstraint.identifier = "text7ViewLeadingAnchorConstraint"
    text7ViewTrailingAnchorConstraint.identifier = "text7ViewTrailingAnchorConstraint"
    view6ViewWidthAnchorConstraint.identifier = "view6ViewWidthAnchorConstraint"
    text8ViewTopAnchorConstraint.identifier = "text8ViewTopAnchorConstraint"
    text8ViewBottomAnchorConstraint.identifier = "text8ViewBottomAnchorConstraint"
    text8ViewLeadingAnchorConstraint.identifier = "text8ViewLeadingAnchorConstraint"
    text8ViewTrailingAnchorConstraint.identifier = "text8ViewTrailingAnchorConstraint"
    text9ViewTopAnchorConstraint.identifier = "text9ViewTopAnchorConstraint"
    text9ViewLeadingAnchorConstraint.identifier = "text9ViewLeadingAnchorConstraint"
    text9ViewTrailingAnchorConstraint.identifier = "text9ViewTrailingAnchorConstraint"
    text10ViewTopAnchorConstraint.identifier = "text10ViewTopAnchorConstraint"
    text10ViewLeadingAnchorConstraint.identifier = "text10ViewLeadingAnchorConstraint"
    text10ViewTrailingAnchorConstraint.identifier = "text10ViewTrailingAnchorConstraint"
    image1ViewBottomAnchorConstraint.identifier = "image1ViewBottomAnchorConstraint"
    image1ViewTopAnchorConstraint.identifier = "image1ViewTopAnchorConstraint"
    image1ViewTrailingAnchorConstraint.identifier = "image1ViewTrailingAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
    text4ViewWidthAnchorConstraint.identifier = "text4ViewWidthAnchorConstraint"
    image1ViewHeightAnchorConstraint.identifier = "image1ViewHeightAnchorConstraint"
    image1ViewWidthAnchorConstraint.identifier = "image1ViewWidthAnchorConstraint"
  }

  private func update() {}
}
