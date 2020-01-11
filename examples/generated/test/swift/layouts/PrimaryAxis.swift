import UIKit
import Foundation

// MARK: - PrimaryAxis

public class PrimaryAxis: UIView {

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

  private var fixedView = UIView(frame: .zero)
  private var fitView = UIView(frame: .zero)
  private var textView = UILabel()
  private var fill1View = UIView(frame: .zero)
  private var fill2View = UIView(frame: .zero)

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    textView.isUserInteractionEnabled = false
    textView.numberOfLines = 0

    addSubview(fixedView)
    addSubview(fitView)
    addSubview(fill1View)
    addSubview(fill2View)
    fitView.addSubview(textView)

    fixedView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fitView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedText = textViewTextStyle.apply(to: "Text goes here")
    fill1View.backgroundColor = Colors.cyan500
    fill2View.backgroundColor = Colors.blue500
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    fixedView.translatesAutoresizingMaskIntoConstraints = false
    fitView.translatesAutoresizingMaskIntoConstraints = false
    fill1View.translatesAutoresizingMaskIntoConstraints = false
    fill2View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 500)
    let fill1ViewFill2ViewHeightAnchorSiblingConstraint = fill1View
      .heightAnchor
      .constraint(equalTo: fill2View.heightAnchor)
    let fixedViewTopAnchorConstraint = fixedView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let fixedViewLeadingAnchorConstraint = fixedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fitViewTopAnchorConstraint = fitView.topAnchor.constraint(equalTo: fixedView.bottomAnchor, constant: 24)
    let fitViewLeadingAnchorConstraint = fitView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fill1ViewTopAnchorConstraint = fill1View.topAnchor.constraint(equalTo: fitView.bottomAnchor, constant: 24)
    let fill1ViewLeadingAnchorConstraint = fill1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fill2ViewBottomAnchorConstraint = fill2View.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
    let fill2ViewTopAnchorConstraint = fill2View.topAnchor.constraint(equalTo: fill1View.bottomAnchor)
    let fill2ViewLeadingAnchorConstraint = fill2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let fixedViewHeightAnchorConstraint = fixedView.heightAnchor.constraint(equalToConstant: 100)
    let fixedViewWidthAnchorConstraint = fixedView.widthAnchor.constraint(equalToConstant: 100)
    let fitViewWidthAnchorConstraint = fitView.widthAnchor.constraint(equalToConstant: 100)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: fitView.topAnchor)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: fitView.bottomAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: fitView.leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: fitView.trailingAnchor)
    let fill1ViewWidthAnchorConstraint = fill1View.widthAnchor.constraint(equalToConstant: 100)
    let fill2ViewWidthAnchorConstraint = fill2View.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      fill1ViewFill2ViewHeightAnchorSiblingConstraint,
      fixedViewTopAnchorConstraint,
      fixedViewLeadingAnchorConstraint,
      fitViewTopAnchorConstraint,
      fitViewLeadingAnchorConstraint,
      fill1ViewTopAnchorConstraint,
      fill1ViewLeadingAnchorConstraint,
      fill2ViewBottomAnchorConstraint,
      fill2ViewTopAnchorConstraint,
      fill2ViewLeadingAnchorConstraint,
      fixedViewHeightAnchorConstraint,
      fixedViewWidthAnchorConstraint,
      fitViewWidthAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      fill1ViewWidthAnchorConstraint,
      fill2ViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension PrimaryAxis {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension PrimaryAxis {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PrimaryAxis"
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
