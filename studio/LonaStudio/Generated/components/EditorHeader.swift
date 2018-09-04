import AppKit
import Foundation

// MARK: - EditorHeader

public class EditorHeader: NSBox {

  // MARK: Lifecycle

  public init(titleText: String, subtitleText: String, dividerColor: NSColor, fileIcon: NSImage) {
    self.titleText = titleText
    self.subtitleText = subtitleText
    self.dividerColor = dividerColor
    self.fileIcon = fileIcon

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(titleText: "", subtitleText: "", dividerColor: NSColor.clear, fileIcon: NSImage())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var titleText: String { didSet { update() } }
  public var subtitleText: String { didSet { update() } }
  public var dividerColor: NSColor { didSet { update() } }
  public var fileIcon: NSImage { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var imageView = NSImageView()
  private var titleView = NSTextField(labelWithString: "")
  private var subtitleView = NSTextField(labelWithString: "")
  private var dividerView = NSBox()

  private var titleViewTextStyle = TextStyles.regular
  private var subtitleViewTextStyle = TextStyles.regularMuted

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 0
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 0
  private var dividerViewTopMargin: CGFloat = 0
  private var dividerViewTrailingMargin: CGFloat = 0
  private var dividerViewBottomMargin: CGFloat = 0
  private var dividerViewLeadingMargin: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 4
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var subtitleViewTopMargin: CGFloat = 0
  private var subtitleViewTrailingMargin: CGFloat = 0
  private var subtitleViewBottomMargin: CGFloat = 0
  private var subtitleViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var innerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var titleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewTopAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var subtitleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var dividerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    subtitleView.lineBreakMode = .byWordWrapping

    addSubview(innerView)
    addSubview(dividerView)
    innerView.addSubview(imageView)
    innerView.addSubview(titleView)
    innerView.addSubview(subtitleView)

    fillColor = Colors.headerBackground
    titleViewTextStyle = TextStyles.regular
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    subtitleViewTextStyle = TextStyles.regularMuted
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    subtitleView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 38)
    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + innerViewTopMargin)
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(greaterThanOrEqualTo: leadingAnchor, constant: leadingPadding + innerViewLeadingMargin)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let innerViewTrailingAnchorConstraint = innerView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + innerViewTrailingMargin))
    let dividerViewBottomAnchorConstraint = dividerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + dividerViewBottomMargin))
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: innerView.bottomAnchor, constant: innerViewBottomMargin + dividerViewTopMargin)
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + dividerViewLeadingMargin)
    let dividerViewCenterXAnchorConstraint = dividerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + dividerViewTrailingMargin))
    let imageViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + imageViewLeadingMargin)
    let imageViewCenterYAnchorConstraint = imageView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor, constant: 0)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: imageViewTrailingMargin + titleViewLeadingMargin)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(greaterThanOrEqualTo: innerView.topAnchor, constant: innerViewTopPadding + titleViewTopMargin)
    let titleViewCenterYAnchorConstraint = titleView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor, constant: 0)
    let titleViewBottomAnchorConstraint = titleView
      .bottomAnchor
      .constraint(
        lessThanOrEqualTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + titleViewBottomMargin))
    let subtitleViewTrailingAnchorConstraint = subtitleView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -(innerViewTrailingPadding + subtitleViewTrailingMargin))
    let subtitleViewLeadingAnchorConstraint = subtitleView
      .leadingAnchor
      .constraint(equalTo: titleView.trailingAnchor, constant: titleViewTrailingMargin + subtitleViewLeadingMargin)
    let subtitleViewTopAnchorConstraint = subtitleView
      .topAnchor
      .constraint(greaterThanOrEqualTo: innerView.topAnchor, constant: innerViewTopPadding + subtitleViewTopMargin)
    let subtitleViewCenterYAnchorConstraint = subtitleView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor, constant: 0)
    let subtitleViewBottomAnchorConstraint = subtitleView
      .bottomAnchor
      .constraint(
        lessThanOrEqualTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + subtitleViewBottomMargin))
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 16)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 16)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      dividerViewBottomAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewCenterXAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewCenterYAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      subtitleViewTrailingAnchorConstraint,
      subtitleViewLeadingAnchorConstraint,
      subtitleViewTopAnchorConstraint,
      subtitleViewCenterYAnchorConstraint,
      subtitleViewBottomAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewCenterXAnchorConstraint = innerViewCenterXAnchorConstraint
    self.innerViewTrailingAnchorConstraint = innerViewTrailingAnchorConstraint
    self.dividerViewBottomAnchorConstraint = dividerViewBottomAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewCenterXAnchorConstraint = dividerViewCenterXAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.imageViewLeadingAnchorConstraint = imageViewLeadingAnchorConstraint
    self.imageViewCenterYAnchorConstraint = imageViewCenterYAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewCenterYAnchorConstraint = titleViewCenterYAnchorConstraint
    self.titleViewBottomAnchorConstraint = titleViewBottomAnchorConstraint
    self.subtitleViewTrailingAnchorConstraint = subtitleViewTrailingAnchorConstraint
    self.subtitleViewLeadingAnchorConstraint = subtitleViewLeadingAnchorConstraint
    self.subtitleViewTopAnchorConstraint = subtitleViewTopAnchorConstraint
    self.subtitleViewCenterYAnchorConstraint = subtitleViewCenterYAnchorConstraint
    self.subtitleViewBottomAnchorConstraint = subtitleViewBottomAnchorConstraint
    self.dividerViewHeightAnchorConstraint = dividerViewHeightAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewCenterXAnchorConstraint.identifier = "innerViewCenterXAnchorConstraint"
    innerViewTrailingAnchorConstraint.identifier = "innerViewTrailingAnchorConstraint"
    dividerViewBottomAnchorConstraint.identifier = "dividerViewBottomAnchorConstraint"
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewCenterXAnchorConstraint.identifier = "dividerViewCenterXAnchorConstraint"
    dividerViewTrailingAnchorConstraint.identifier = "dividerViewTrailingAnchorConstraint"
    imageViewLeadingAnchorConstraint.identifier = "imageViewLeadingAnchorConstraint"
    imageViewCenterYAnchorConstraint.identifier = "imageViewCenterYAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewCenterYAnchorConstraint.identifier = "titleViewCenterYAnchorConstraint"
    titleViewBottomAnchorConstraint.identifier = "titleViewBottomAnchorConstraint"
    subtitleViewTrailingAnchorConstraint.identifier = "subtitleViewTrailingAnchorConstraint"
    subtitleViewLeadingAnchorConstraint.identifier = "subtitleViewLeadingAnchorConstraint"
    subtitleViewTopAnchorConstraint.identifier = "subtitleViewTopAnchorConstraint"
    subtitleViewCenterYAnchorConstraint.identifier = "subtitleViewCenterYAnchorConstraint"
    subtitleViewBottomAnchorConstraint.identifier = "subtitleViewBottomAnchorConstraint"
    dividerViewHeightAnchorConstraint.identifier = "dividerViewHeightAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
  }

  private func update() {
    dividerView.fillColor = dividerColor
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleText)
    imageView.image = fileIcon
  }
}
