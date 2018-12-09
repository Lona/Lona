import AppKit
import Foundation

// MARK: - CanvasTableHeaderItem

public class CanvasTableHeaderItem: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(titleText: String, dividerColor: NSColor) {
    self.init(Parameters(titleText: titleText, dividerColor: dividerColor))
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

  public var dividerColor: NSColor {
    get { return parameters.dividerColor }
    set {
      if parameters.dividerColor != newValue {
        parameters.dividerColor = newValue
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
  private var titleView = LNATextField(labelWithString: "")
  private var vDividerView = NSBox()
  private var hDividerView = NSBox()

  private var titleViewTextStyle = TextStyles.sectionTitle.with(alignment: .center)

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    hDividerView.boxType = .custom
    hDividerView.borderType = .noBorder
    hDividerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vDividerView.boxType = .custom
    vDividerView.borderType = .noBorder
    vDividerView.contentViewMargins = .zero

    addSubview(innerView)
    addSubview(hDividerView)
    innerView.addSubview(titleView)
    innerView.addSubview(vDividerView)

    fillColor = Colors.white
    titleViewTextStyle = TextStyles.sectionTitle.with(alignment: .center)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    hDividerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    vDividerView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 38)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let hDividerViewBottomAnchorConstraint = hDividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let hDividerViewTopAnchorConstraint = hDividerView.topAnchor.constraint(equalTo: innerView.bottomAnchor)
    let hDividerViewLeadingAnchorConstraint = hDividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let hDividerViewCenterXAnchorConstraint = hDividerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let hDividerViewTrailingAnchorConstraint = hDividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(lessThanOrEqualTo: innerView.bottomAnchor)
    let vDividerViewTrailingAnchorConstraint = vDividerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let vDividerViewLeadingAnchorConstraint = vDividerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let vDividerViewTopAnchorConstraint = vDividerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let vDividerViewCenterYAnchorConstraint = vDividerView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
    let vDividerViewBottomAnchorConstraint = vDividerView.bottomAnchor.constraint(equalTo: innerView.bottomAnchor)
    let hDividerViewHeightAnchorConstraint = hDividerView.heightAnchor.constraint(equalToConstant: 1)
    let vDividerViewWidthAnchorConstraint = vDividerView.widthAnchor.constraint(equalToConstant: 1)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      hDividerViewBottomAnchorConstraint,
      hDividerViewTopAnchorConstraint,
      hDividerViewLeadingAnchorConstraint,
      hDividerViewCenterXAnchorConstraint,
      hDividerViewTrailingAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      vDividerViewTrailingAnchorConstraint,
      vDividerViewLeadingAnchorConstraint,
      vDividerViewTopAnchorConstraint,
      vDividerViewCenterYAnchorConstraint,
      vDividerViewBottomAnchorConstraint,
      hDividerViewHeightAnchorConstraint,
      vDividerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    hDividerView.fillColor = dividerColor
    vDividerView.fillColor = dividerColor
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
  }
}

// MARK: - Parameters

extension CanvasTableHeaderItem {
  public struct Parameters: Equatable {
    public var titleText: String
    public var dividerColor: NSColor

    public init(titleText: String, dividerColor: NSColor) {
      self.titleText = titleText
      self.dividerColor = dividerColor
    }

    public init() {
      self.init(titleText: "", dividerColor: NSColor.clear)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText && lhs.dividerColor == rhs.dividerColor
    }
  }
}

// MARK: - Model

extension CanvasTableHeaderItem {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "CanvasTableHeaderItem"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(titleText: String, dividerColor: NSColor) {
      self.init(Parameters(titleText: titleText, dividerColor: dividerColor))
    }

    public init() {
      self.init(titleText: "", dividerColor: NSColor.clear)
    }
  }
}
