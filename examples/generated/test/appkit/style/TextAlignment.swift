import AppKit
import Foundation

// MARK: - TextAlignment

public class TextAlignment: NSBox {

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

  private var view1View = NSBox()
  private var view2View = NSBox()
  private var imageView = NSImageView()
  private var textView = NSTextField(labelWithString: "")
  private var text1View = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.display1.with(alignment: .center)
  private var text1ViewTextStyle = TextStyles.subheading2.with(alignment: .center)

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
  private var view2ViewTopMargin: CGFloat = 0
  private var view2ViewTrailingMargin: CGFloat = 0
  private var view2ViewBottomMargin: CGFloat = 0
  private var view2ViewLeadingMargin: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 0
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0
  private var textViewTopMargin: CGFloat = 16
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0
  private var text1ViewTopMargin: CGFloat = 16
  private var text1ViewTrailingMargin: CGFloat = 0
  private var text1ViewBottomMargin: CGFloat = 0
  private var text1ViewLeadingMargin: CGFloat = 0

  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    text1View.lineBreakMode = .byWordWrapping

    addSubview(view1View)
    view1View.addSubview(view2View)
    view1View.addSubview(imageView)
    view1View.addSubview(textView)
    view1View.addSubview(text1View)

    view2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    imageView.image = NSImage(named: NSImage.Name(rawValue: "icon_128x128"))
    textViewTextStyle = TextStyles.display1.with(alignment: .center)
    textView.attributedStringValue = textViewTextStyle.apply(to: "Welcome to Lona Studio")
    text1ViewTextStyle = TextStyles.subheading2.with(alignment: .center)
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Version 1.0.2")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let view1ViewBottomAnchorConstraint = view1View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + view1ViewBottomMargin))
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTrailingAnchorConstraint = view1View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view1ViewTrailingMargin))
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 400)
    let view2ViewTopAnchorConstraint = view2View
      .topAnchor
      .constraint(equalTo: view1View.topAnchor, constant: view1ViewTopPadding + view2ViewTopMargin)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + view2ViewLeadingMargin)
    let view2ViewTrailingAnchorConstraint = view2View
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: view1View.trailingAnchor,
        constant: -(view1ViewTrailingPadding + view2ViewTrailingMargin))
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: view2View.bottomAnchor, constant: view2ViewBottomMargin + imageViewTopMargin)
    let imageViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + imageViewLeadingMargin)
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: imageView.bottomAnchor, constant: imageViewBottomMargin + textViewTopMargin)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: -(view1ViewTrailingPadding + textViewTrailingMargin))
    let text1ViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(equalTo: textView.bottomAnchor, constant: textViewBottomMargin + text1ViewTopMargin)
    let text1ViewLeadingAnchorConstraint = text1View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + text1ViewLeadingMargin)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: -(view1ViewTrailingPadding + text1ViewTrailingMargin))
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])

    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view1ViewBottomAnchorConstraint = view1ViewBottomAnchorConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTrailingAnchorConstraint = view1ViewTrailingAnchorConstraint
    self.view1ViewHeightAnchorConstraint = view1ViewHeightAnchorConstraint
    self.view2ViewTopAnchorConstraint = view2ViewTopAnchorConstraint
    self.view2ViewLeadingAnchorConstraint = view2ViewLeadingAnchorConstraint
    self.view2ViewTrailingAnchorConstraint = view2ViewTrailingAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewLeadingAnchorConstraint = imageViewLeadingAnchorConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.text1ViewTopAnchorConstraint = text1ViewTopAnchorConstraint
    self.text1ViewLeadingAnchorConstraint = text1ViewLeadingAnchorConstraint
    self.text1ViewTrailingAnchorConstraint = text1ViewTrailingAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint

    // For debugging
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view1ViewBottomAnchorConstraint.identifier = "view1ViewBottomAnchorConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTrailingAnchorConstraint.identifier = "view1ViewTrailingAnchorConstraint"
    view1ViewHeightAnchorConstraint.identifier = "view1ViewHeightAnchorConstraint"
    view2ViewTopAnchorConstraint.identifier = "view2ViewTopAnchorConstraint"
    view2ViewLeadingAnchorConstraint.identifier = "view2ViewLeadingAnchorConstraint"
    view2ViewTrailingAnchorConstraint.identifier = "view2ViewTrailingAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewLeadingAnchorConstraint.identifier = "imageViewLeadingAnchorConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    text1ViewTopAnchorConstraint.identifier = "text1ViewTopAnchorConstraint"
    text1ViewLeadingAnchorConstraint.identifier = "text1ViewLeadingAnchorConstraint"
    text1ViewTrailingAnchorConstraint.identifier = "text1ViewTrailingAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
  }

  private func update() {}
}