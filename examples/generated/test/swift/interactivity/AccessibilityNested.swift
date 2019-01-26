import UIKit
import Foundation

// MARK: - AccessibilityNested

public class AccessibilityNested: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
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

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var accessibilityTestView = AccessibilityTest()
  private var accessibilityVisibilityView = AccessibilityVisibility()

  private func setUpViews() {
    addSubview(accessibilityTestView)
    addSubview(accessibilityVisibilityView)

    accessibilityTestView.checkboxValue = false
    accessibilityTestView.customTextAccessibilityLabel = "Text"
    accessibilityVisibilityView.showText = false
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    accessibilityTestView.translatesAutoresizingMaskIntoConstraints = false
    accessibilityVisibilityView.translatesAutoresizingMaskIntoConstraints = false

    let accessibilityTestViewTopAnchorConstraint = accessibilityTestView.topAnchor.constraint(equalTo: topAnchor)
    let accessibilityTestViewLeadingAnchorConstraint = accessibilityTestView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let accessibilityTestViewTrailingAnchorConstraint = accessibilityTestView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let accessibilityVisibilityViewBottomAnchorConstraint = accessibilityVisibilityView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor)
    let accessibilityVisibilityViewTopAnchorConstraint = accessibilityVisibilityView
      .topAnchor
      .constraint(equalTo: accessibilityTestView.bottomAnchor)
    let accessibilityVisibilityViewLeadingAnchorConstraint = accessibilityVisibilityView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let accessibilityVisibilityViewTrailingAnchorConstraint = accessibilityVisibilityView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      accessibilityTestViewTopAnchorConstraint,
      accessibilityTestViewLeadingAnchorConstraint,
      accessibilityTestViewTrailingAnchorConstraint,
      accessibilityVisibilityViewBottomAnchorConstraint,
      accessibilityVisibilityViewTopAnchorConstraint,
      accessibilityVisibilityViewLeadingAnchorConstraint,
      accessibilityVisibilityViewTrailingAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension AccessibilityNested {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension AccessibilityNested {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "AccessibilityNested"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
