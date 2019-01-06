import AppKit
import Foundation

// MARK: - ComponentBrowser

public class ComponentBrowser: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(readme: String, componentNames: [String], folderName: String) {
    self.init(Parameters(readme: readme, componentNames: componentNames, folderName: folderName))
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

  public var readme: String {
    get { return parameters.readme }
    set {
      if parameters.readme != newValue {
        parameters.readme = newValue
      }
    }
  }

  public var componentNames: [String] {
    get { return parameters.componentNames }
    set {
      if parameters.componentNames != newValue {
        parameters.componentNames = newValue
      }
    }
  }

  public var folderName: String {
    get { return parameters.folderName }
    set {
      if parameters.folderName != newValue {
        parameters.folderName = newValue
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
  private var spacerView = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var spacer2View = NSBox()
  private var componentPreviewCollectionView = ComponentPreviewCollection()

  private var titleViewTextStyle = TextStyles.title
  private var textViewTextStyle = TextStyles.regular

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    spacer2View.boxType = .custom
    spacer2View.borderType = .noBorder
    spacer2View.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(titleView)
    innerView.addSubview(spacerView)
    innerView.addSubview(textView)
    innerView.addSubview(spacer2View)
    innerView.addSubview(componentPreviewCollectionView)

    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    spacer2View.translatesAutoresizingMaskIntoConstraints = false
    componentPreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 64)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: innerView.trailingAnchor, constant: -64)
    let spacerViewTopAnchorConstraint = spacerView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 64)
    let spacerViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -64)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: spacerView.bottomAnchor)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 64)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -64)
    let spacer2ViewTopAnchorConstraint = spacer2View.topAnchor.constraint(equalTo: textView.bottomAnchor)
    let spacer2ViewLeadingAnchorConstraint = spacer2View
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 64)
    let spacer2ViewTrailingAnchorConstraint = spacer2View
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -64)
    let componentPreviewCollectionViewBottomAnchorConstraint = componentPreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let componentPreviewCollectionViewTopAnchorConstraint = componentPreviewCollectionView
      .topAnchor
      .constraint(equalTo: spacer2View.bottomAnchor)
    let componentPreviewCollectionViewLeadingAnchorConstraint = componentPreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: 64)
    let componentPreviewCollectionViewTrailingAnchorConstraint = componentPreviewCollectionView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -64)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 24)
    let spacer2ViewHeightAnchorConstraint = spacer2View.heightAnchor.constraint(equalToConstant: 24)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewTrailingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      spacer2ViewTopAnchorConstraint,
      spacer2ViewLeadingAnchorConstraint,
      spacer2ViewTrailingAnchorConstraint,
      componentPreviewCollectionViewBottomAnchorConstraint,
      componentPreviewCollectionViewTopAnchorConstraint,
      componentPreviewCollectionViewLeadingAnchorConstraint,
      componentPreviewCollectionViewTrailingAnchorConstraint,
      spacerViewHeightAnchorConstraint,
      spacer2ViewHeightAnchorConstraint
    ])
  }

  private func update() {
    textView.attributedStringValue = textViewTextStyle.apply(to: readme)
    componentPreviewCollectionView.componentNames = componentNames
    titleView.attributedStringValue = titleViewTextStyle.apply(to: folderName)
  }
}

// MARK: - Parameters

extension ComponentBrowser {
  public struct Parameters: Equatable {
    public var readme: String
    public var componentNames: [String]
    public var folderName: String

    public init(readme: String, componentNames: [String], folderName: String) {
      self.readme = readme
      self.componentNames = componentNames
      self.folderName = folderName
    }

    public init() {
      self.init(readme: "", componentNames: [], folderName: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.readme == rhs.readme && lhs.componentNames == rhs.componentNames && lhs.folderName == rhs.folderName
    }
  }
}

// MARK: - Model

extension ComponentBrowser {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ComponentBrowser"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(readme: String, componentNames: [String], folderName: String) {
      self.init(Parameters(readme: readme, componentNames: componentNames, folderName: folderName))
    }

    public init() {
      self.init(readme: "", componentNames: [], folderName: "")
    }
  }
}
