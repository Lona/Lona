import AppKit
import Foundation

// MARK: - TextStylesTest

public class TextStylesTest: NSBox {

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

  private var textView = NSTextField(labelWithString: "")
  private var text1View = NSTextField(labelWithString: "")
  private var text2View = NSTextField(labelWithString: "")
  private var text3View = NSTextField(labelWithString: "")
  private var text4View = NSTextField(labelWithString: "")
  private var text5View = NSTextField(labelWithString: "")
  private var text6View = NSTextField(labelWithString: "")
  private var text7View = NSTextField(labelWithString: "")
  private var text8View = NSTextField(labelWithString: "")
  private var text9View = NSTextField(labelWithString: "")

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

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    text1View.lineBreakMode = .byWordWrapping
    text2View.lineBreakMode = .byWordWrapping
    text3View.lineBreakMode = .byWordWrapping
    text4View.lineBreakMode = .byWordWrapping
    text5View.lineBreakMode = .byWordWrapping
    text6View.lineBreakMode = .byWordWrapping
    text7View.lineBreakMode = .byWordWrapping
    text8View.lineBreakMode = .byWordWrapping
    text9View.lineBreakMode = .byWordWrapping

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

    textView.attributedStringValue = textViewTextStyle.apply(to: "Text goes here")
    textViewTextStyle = TextStyles.display4
    textView.attributedStringValue = textViewTextStyle.apply(to: textView.attributedStringValue)
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Text goes here")
    text1ViewTextStyle = TextStyles.display3
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: text1View.attributedStringValue)
    text2View.attributedStringValue = text2ViewTextStyle.apply(to: "Text goes here")
    text2ViewTextStyle = TextStyles.display2
    text2View.attributedStringValue = text2ViewTextStyle.apply(to: text2View.attributedStringValue)
    text3View.attributedStringValue = text3ViewTextStyle.apply(to: "Text goes here")
    text3ViewTextStyle = TextStyles.display1
    text3View.attributedStringValue = text3ViewTextStyle.apply(to: text3View.attributedStringValue)
    text4View.attributedStringValue = text4ViewTextStyle.apply(to: "Text goes here")
    text4ViewTextStyle = TextStyles.headline
    text4View.attributedStringValue = text4ViewTextStyle.apply(to: text4View.attributedStringValue)
    text5View.attributedStringValue = text5ViewTextStyle.apply(to: "Text goes here")
    text5ViewTextStyle = TextStyles.subheading2
    text5View.attributedStringValue = text5ViewTextStyle.apply(to: text5View.attributedStringValue)
    text6View.attributedStringValue = text6ViewTextStyle.apply(to: "Text goes here")
    text6ViewTextStyle = TextStyles.subheading1
    text6View.attributedStringValue = text6ViewTextStyle.apply(to: text6View.attributedStringValue)
    text7View.attributedStringValue = text7ViewTextStyle.apply(to: "Text goes here")
    text7ViewTextStyle = TextStyles.body2
    text7View.attributedStringValue = text7ViewTextStyle.apply(to: text7View.attributedStringValue)
    text8View.attributedStringValue = text8ViewTextStyle.apply(to: "Text goes here")
    text8ViewTextStyle = TextStyles.body1
    text8View.attributedStringValue = text8ViewTextStyle.apply(to: text8View.attributedStringValue)
    text9View.attributedStringValue = text9ViewTextStyle.apply(to: "Text goes here")
    text9ViewTextStyle = TextStyles.caption
    text9View.attributedStringValue = text9ViewTextStyle.apply(to: text9View.attributedStringValue)
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

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text1ViewTopAnchorConstraint = text1View.topAnchor.constraint(equalTo: textView.bottomAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text1ViewTrailingAnchorConstraint = text1View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text2ViewTopAnchorConstraint = text2View.topAnchor.constraint(equalTo: text1View.bottomAnchor)
    let text2ViewLeadingAnchorConstraint = text2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text2ViewTrailingAnchorConstraint = text2View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text3ViewTopAnchorConstraint = text3View.topAnchor.constraint(equalTo: text2View.bottomAnchor)
    let text3ViewLeadingAnchorConstraint = text3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text3ViewTrailingAnchorConstraint = text3View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text4ViewTopAnchorConstraint = text4View.topAnchor.constraint(equalTo: text3View.bottomAnchor)
    let text4ViewLeadingAnchorConstraint = text4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text4ViewTrailingAnchorConstraint = text4View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text5ViewTopAnchorConstraint = text5View.topAnchor.constraint(equalTo: text4View.bottomAnchor)
    let text5ViewLeadingAnchorConstraint = text5View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text5ViewTrailingAnchorConstraint = text5View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text6ViewTopAnchorConstraint = text6View.topAnchor.constraint(equalTo: text5View.bottomAnchor)
    let text6ViewLeadingAnchorConstraint = text6View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text6ViewTrailingAnchorConstraint = text6View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text7ViewTopAnchorConstraint = text7View.topAnchor.constraint(equalTo: text6View.bottomAnchor)
    let text7ViewLeadingAnchorConstraint = text7View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text7ViewTrailingAnchorConstraint = text7View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text8ViewTopAnchorConstraint = text8View.topAnchor.constraint(equalTo: text7View.bottomAnchor)
    let text8ViewLeadingAnchorConstraint = text8View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text8ViewTrailingAnchorConstraint = text8View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text9ViewBottomAnchorConstraint = text9View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let text9ViewTopAnchorConstraint = text9View.topAnchor.constraint(equalTo: text8View.bottomAnchor)
    let text9ViewLeadingAnchorConstraint = text9View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text9ViewTrailingAnchorConstraint = text9View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)

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
  }

  private func update() {}
}
