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
  private var imageView = LNAImageView()
  private var titleView = LNATextField(labelWithString: "")
  private var subtitleView = LNATextField(labelWithString: "")
  private var dividerView = NSBox()

  private var titleViewTextStyle = TextStyles.regular
  private var subtitleViewTextStyle = TextStyles.regularDisabled

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
    subtitleViewTextStyle = TextStyles.regularDisabled
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
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let dividerViewBottomAnchorConstraint = dividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: innerView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let dividerViewCenterXAnchorConstraint = dividerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let dividerViewTrailingAnchorConstraint = dividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let imageViewCenterYAnchorConstraint = imageView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: 4)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let subtitleViewTrailingAnchorConstraint = subtitleView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let subtitleViewLeadingAnchorConstraint = subtitleView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let subtitleViewTopAnchorConstraint = subtitleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let subtitleViewCenterYAnchorConstraint = subtitleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let subtitleViewBottomAnchorConstraint = subtitleView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: innerView.bottomAnchor)
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
  }

  private func update() {
    dividerView.fillColor = dividerColor
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleText)
    imageView.image = fileIcon
  }
}
