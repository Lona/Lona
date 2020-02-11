import AppKit
import Foundation

// MARK: - EditorHeader

public class EditorHeader: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(titleText: String, subtitleText: String, dividerColor: NSColor, fileIcon: NSImage?) {
    self
      .init(
        Parameters(titleText: titleText, subtitleText: subtitleText, dividerColor: dividerColor, fileIcon: fileIcon))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var subtitleText: String {
    get { return parameters.subtitleText }
    set {
      if parameters.subtitleText != newValue {
        parameters.subtitleText = newValue
      }
    }
  }

  public var dividerColor: NSColor {
    get { return parameters.dividerColor }
    set {
      if parameters.dividerColor != newValue {
        parameters.dividerColor = newValue
      }
    }
  }

  public var fileIcon: NSImage? {
    get { return parameters.fileIcon }
    set {
      if parameters.fileIcon != newValue {
        parameters.fileIcon = newValue
      }
    }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var innerView = NSBox()
  private var imageView = LNAImageView()
  private var titleView = LNATextField(labelWithString: "")
  private var subtitleView = LNATextField(labelWithString: "")
  private var dividerView = NSBox()

  private var titleViewTextStyle = TextStyles.regular
  private var subtitleViewTextStyle = TextStyles.regularDisabled

  private var titleViewLeadingAnchorInnerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var imageViewLeadingAnchorInnerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterYAnchorInnerViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorImageViewTrailingAnchorConstraint: NSLayoutConstraint?
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
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let subtitleViewTrailingAnchorConstraint = subtitleView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -10)
    let subtitleViewLeadingAnchorConstraint = subtitleView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let subtitleViewTopAnchorConstraint = subtitleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let subtitleViewCenterYAnchorConstraint = subtitleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let subtitleViewBottomAnchorConstraint = subtitleView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let titleViewLeadingAnchorInnerViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 10)
    let imageViewLeadingAnchorInnerViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 10)
    let imageViewCenterYAnchorInnerViewCenterYAnchorConstraint = imageView
      .centerYAnchor
      .constraint(equalTo: innerView.centerYAnchor)
    let titleViewLeadingAnchorImageViewTrailingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: imageView.trailingAnchor, constant: 4)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 16)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 16)

    self.titleViewLeadingAnchorInnerViewLeadingAnchorConstraint = titleViewLeadingAnchorInnerViewLeadingAnchorConstraint
    self.imageViewLeadingAnchorInnerViewLeadingAnchorConstraint = imageViewLeadingAnchorInnerViewLeadingAnchorConstraint
    self.imageViewCenterYAnchorInnerViewCenterYAnchorConstraint = imageViewCenterYAnchorInnerViewCenterYAnchorConstraint
    self.titleViewLeadingAnchorImageViewTrailingAnchorConstraint =
      titleViewLeadingAnchorImageViewTrailingAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint

    NSLayoutConstraint.activate(
      [
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
        titleViewTopAnchorConstraint,
        titleViewCenterYAnchorConstraint,
        titleViewBottomAnchorConstraint,
        subtitleViewTrailingAnchorConstraint,
        subtitleViewLeadingAnchorConstraint,
        subtitleViewTopAnchorConstraint,
        subtitleViewCenterYAnchorConstraint,
        subtitleViewBottomAnchorConstraint,
        dividerViewHeightAnchorConstraint
      ] +
        conditionalConstraints(imageViewIsHidden: imageView.isHidden))
  }

  private func conditionalConstraints(imageViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (imageViewIsHidden) {
      case (true):
        constraints = [titleViewLeadingAnchorInnerViewLeadingAnchorConstraint]
      case (false):
        constraints = [
          imageViewLeadingAnchorInnerViewLeadingAnchorConstraint,
          imageViewCenterYAnchorInnerViewCenterYAnchorConstraint,
          titleViewLeadingAnchorImageViewTrailingAnchorConstraint,
          imageViewHeightAnchorConstraint,
          imageViewWidthAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let imageViewIsHidden = imageView.isHidden

    imageView.isHidden = !false
    imageView.image = NSImage()
    dividerView.fillColor = dividerColor
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    subtitleView.attributedStringValue = subtitleViewTextStyle.apply(to: subtitleText)
    if let iconImage = fileIcon {
      imageView.image = iconImage
      imageView.isHidden = !true
    }

    if imageView.isHidden != imageViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(imageViewIsHidden: imageViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(imageViewIsHidden: imageView.isHidden))
    }
  }
}

// MARK: - Parameters

extension EditorHeader {
  public struct Parameters: Equatable {
    public var titleText: String
    public var subtitleText: String
    public var dividerColor: NSColor
    public var fileIcon: NSImage?

    public init(titleText: String, subtitleText: String, dividerColor: NSColor, fileIcon: NSImage? = nil) {
      self.titleText = titleText
      self.subtitleText = subtitleText
      self.dividerColor = dividerColor
      self.fileIcon = fileIcon
    }

    public init() {
      self.init(titleText: "", subtitleText: "", dividerColor: NSColor.clear, fileIcon: nil)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText &&
        lhs.subtitleText == rhs.subtitleText && lhs.dividerColor == rhs.dividerColor && lhs.fileIcon == rhs.fileIcon
    }
  }
}

// MARK: - Model

extension EditorHeader {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "EditorHeader"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(titleText: String, subtitleText: String, dividerColor: NSColor, fileIcon: NSImage? = nil) {
      self
        .init(
          Parameters(titleText: titleText, subtitleText: subtitleText, dividerColor: dividerColor, fileIcon: fileIcon))
    }

    public init() {
      self.init(titleText: "", subtitleText: "", dividerColor: NSColor.clear, fileIcon: nil)
    }
  }
}

// LONA: KEEP BELOW

extension EditorHeader {
    public override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
