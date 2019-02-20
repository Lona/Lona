// Compiled by Lona Version 0.5.2

import UIKit
import Foundation

// MARK: - Assign

public class Assign: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(text: String) {
    self.init(Parameters(text: text))
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

  public var text: String {
    get { return parameters.text }
    set {
      if parameters.text != newValue {
        parameters.text = newValue
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

  private var textView = UILabel()

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    textView.isUserInteractionEnabled = false
    textView.numberOfLines = 0

    addSubview(textView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    textView.attributedText = textViewTextStyle.apply(to: text)
  }
}

// MARK: - Parameters

extension Assign {
  public struct Parameters: Equatable {
    public var text: String

    public init(text: String) {
      self.text = text
    }

    public init() {
      self.init(text: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.text == rhs.text
    }
  }
}

// MARK: - Model

extension Assign {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "Assign"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(text: String) {
      self.init(Parameters(text: text))
    }

    public init() {
      self.init(text: "")
    }
  }
}
