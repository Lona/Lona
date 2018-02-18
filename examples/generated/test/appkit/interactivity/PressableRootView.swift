import AppKit
import Foundation

// MARK: - PressableRootView

public class PressableRootView: NSBox {

  // MARK: Lifecycle

  public init() {
    self.onPress = onPress

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onPress: (() -> Void)?

  // MARK: Private

  private var view1View = NSBox()

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0

  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view1ViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero

    addSubview(view1View)

    view1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let view1ViewBottomAnchorConstraint = view1View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + view1ViewBottomMargin))
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 100)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint
    ])

    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view1ViewBottomAnchorConstraint = view1ViewBottomAnchorConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewHeightAnchorConstraint = view1ViewHeightAnchorConstraint
    self.view1ViewWidthAnchorConstraint = view1ViewWidthAnchorConstraint

    // For debugging
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view1ViewBottomAnchorConstraint.identifier = "view1ViewBottomAnchorConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewHeightAnchorConstraint.identifier = "view1ViewHeightAnchorConstraint"
    view1ViewWidthAnchorConstraint.identifier = "view1ViewWidthAnchorConstraint"
  }

  private func update() {
    onPress = onPress
  }
}
