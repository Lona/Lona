// Compiled by Lona Version 0.5.2

import AppKit
import Foundation

// MARK: - BorderStyleTest

public class BorderStyleTest: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(showDottedBorder: Bool, customBorderStyle: String?, requiredBorderStyle: String) {
    self
      .init(
        Parameters(
          showDottedBorder: showDottedBorder,
          customBorderStyle: customBorderStyle,
          requiredBorderStyle: requiredBorderStyle))
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

  public var showDottedBorder: Bool {
    get { return parameters.showDottedBorder }
    set {
      if parameters.showDottedBorder != newValue {
        parameters.showDottedBorder = newValue
      }
    }
  }

  public var customBorderStyle: String? {
    get { return parameters.customBorderStyle }
    set {
      if parameters.customBorderStyle != newValue {
        parameters.customBorderStyle = newValue
      }
    }
  }

  public var requiredBorderStyle: String {
    get { return parameters.requiredBorderStyle }
    set {
      if parameters.requiredBorderStyle != newValue {
        parameters.requiredBorderStyle = newValue
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
  private var otherView = NSBox()

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .lineBorder
    innerView.contentViewMargins = .zero
    otherView.boxType = .custom
    otherView.borderType = .lineBorder
    otherView.contentViewMargins = .zero

    addSubview(innerView)
    addSubview(otherView)

    borderColor = Colors.greena700
    borderWidth = 2
    innerView.fillColor = Colors.blue50
    innerView.borderColor = Colors.bluea700
    innerView.borderWidth = 10
    otherView.borderColor = Colors.reda700
    otherView.borderWidth = 4
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    otherView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewHeightAnchorParentConstraint = innerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -4)
    let otherViewHeightAnchorParentConstraint = otherView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -4)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 2)
    let otherViewLeadingAnchorConstraint = otherView.leadingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let otherViewTopAnchorConstraint = otherView.topAnchor.constraint(equalTo: topAnchor, constant: 2)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)
    let otherViewHeightAnchorConstraint = otherView.heightAnchor.constraint(equalToConstant: 100)
    let otherViewWidthAnchorConstraint = otherView.widthAnchor.constraint(equalToConstant: 100)

    innerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    otherViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      innerViewHeightAnchorParentConstraint,
      otherViewHeightAnchorParentConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewTopAnchorConstraint,
      otherViewLeadingAnchorConstraint,
      otherViewTopAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint,
      otherViewHeightAnchorConstraint,
      otherViewWidthAnchorConstraint
    ])
  }

  private func update() {


    if showDottedBorder {

    }
    if let customBorderStyle = customBorderStyle {

    }

  }
}

// MARK: - Parameters

extension BorderStyleTest {
  public struct Parameters: Equatable {
    public var showDottedBorder: Bool
    public var customBorderStyle: String?
    public var requiredBorderStyle: String

    public init(showDottedBorder: Bool, customBorderStyle: String? = nil, requiredBorderStyle: String) {
      self.showDottedBorder = showDottedBorder
      self.customBorderStyle = customBorderStyle
      self.requiredBorderStyle = requiredBorderStyle
    }

    public init() {
      self.init(showDottedBorder: false, customBorderStyle: nil, requiredBorderStyle: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.showDottedBorder == rhs.showDottedBorder &&
        lhs.customBorderStyle == rhs.customBorderStyle && lhs.requiredBorderStyle == rhs.requiredBorderStyle
    }
  }
}

// MARK: - Model

extension BorderStyleTest {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "BorderStyleTest"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(showDottedBorder: Bool, customBorderStyle: String? = nil, requiredBorderStyle: String) {
      self
        .init(
          Parameters(
            showDottedBorder: showDottedBorder,
            customBorderStyle: customBorderStyle,
            requiredBorderStyle: requiredBorderStyle))
    }

    public init() {
      self.init(showDottedBorder: false, customBorderStyle: nil, requiredBorderStyle: "")
    }
  }
}
