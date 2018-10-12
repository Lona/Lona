import AppKit
import Foundation

// MARK: - Optionals

public class Optionals: NSBox {

  // MARK: Lifecycle

  public init(boolParam: Bool?, stringParam: String?) {
    self.boolParam = boolParam
    self.stringParam = stringParam

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(boolParam: nil, stringParam: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var boolParam: Bool? { didSet { update() } }
  public var stringParam: String? { didSet { update() } }

  // MARK: Private

  private var labelView = NSTextField(labelWithString: "")
  private var stringParamView = NSTextField(labelWithString: "")

  private var labelViewTextStyle = TextStyles.body1
  private var stringParamViewTextStyle = TextStyles.body1

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    labelView.lineBreakMode = .byWordWrapping
    stringParamView.lineBreakMode = .byWordWrapping

    addSubview(labelView)
    addSubview(stringParamView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    labelView.translatesAutoresizingMaskIntoConstraints = false
    stringParamView.translatesAutoresizingMaskIntoConstraints = false

    let labelViewTopAnchorConstraint = labelView.topAnchor.constraint(equalTo: topAnchor)
    let labelViewLeadingAnchorConstraint = labelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let labelViewTrailingAnchorConstraint = labelView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let stringParamViewBottomAnchorConstraint = stringParamView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let stringParamViewTopAnchorConstraint = stringParamView.topAnchor.constraint(equalTo: labelView.bottomAnchor)
    let stringParamViewLeadingAnchorConstraint = stringParamView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let stringParamViewTrailingAnchorConstraint = stringParamView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor)

    NSLayoutConstraint.activate([
      labelViewTopAnchorConstraint,
      labelViewLeadingAnchorConstraint,
      labelViewTrailingAnchorConstraint,
      stringParamViewBottomAnchorConstraint,
      stringParamViewTopAnchorConstraint,
      stringParamViewLeadingAnchorConstraint,
      stringParamViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    labelView.attributedStringValue = labelViewTextStyle.apply(to: "")
    stringParamView.attributedStringValue = stringParamViewTextStyle.apply(to: "No string param")
    fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    if boolParam == true {
      labelView.attributedStringValue = labelViewTextStyle.apply(to: "boolParam is true")
      fillColor = Colors.green200
    }
    if boolParam == false {
      labelView.attributedStringValue = labelViewTextStyle.apply(to: "boolParam is false")
      fillColor = Colors.red200
    }
    if boolParam == nil {
      labelView.attributedStringValue = labelViewTextStyle.apply(to: "boolParam is null")
    }
    if let unwrapped = stringParam {
      stringParamView.attributedStringValue = stringParamViewTextStyle.apply(to: unwrapped)
    }
  }
}
