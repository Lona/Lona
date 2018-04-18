import AppKit
import Foundation

// MARK: - FitContentParentSecondaryChildren

public class FitContentParentSecondaryChildren: NSBox {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private var view1View = NSBox()
  private var view3View = NSBox()
  private var view2View = NSBox()

  private var topPadding: CGFloat = 24
  private var trailingPadding: CGFloat = 24
  private var bottomPadding: CGFloat = 24
  private var leadingPadding: CGFloat = 24
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0
  private var view3ViewTopMargin: CGFloat = 0
  private var view3ViewTrailingMargin: CGFloat = 0
  private var view3ViewBottomMargin: CGFloat = 0
  private var view3ViewLeadingMargin: CGFloat = 0
  private var view2ViewTopMargin: CGFloat = 0
  private var view2ViewTrailingMargin: CGFloat = 0
  private var view2ViewBottomMargin: CGFloat = 0
  private var view2ViewLeadingMargin: CGFloat = 0

  private var view1ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var view3ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var view2ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view1ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var view3ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view3ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var view2ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view2ViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero

    addSubview(view1View)
    addSubview(view3View)
    addSubview(view2View)

    fillColor = Colors.bluegrey50
    view1View.fillColor = Colors.blue500
    view3View.fillColor = Colors.lightblue500
    view2View.fillColor = Colors.cyan500
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewHeightAnchorParentConstraint = view1View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: heightAnchor,
        constant: -(topPadding + view1ViewTopMargin + bottomPadding + view1ViewBottomMargin))
    let view3ViewHeightAnchorParentConstraint = view3View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: heightAnchor,
        constant: -(topPadding + view3ViewTopMargin + bottomPadding + view3ViewBottomMargin))
    let view2ViewHeightAnchorParentConstraint = view2View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: heightAnchor,
        constant: -(topPadding + view2ViewTopMargin + bottomPadding + view2ViewBottomMargin))
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let view3ViewLeadingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: view1ViewTrailingMargin + view3ViewLeadingMargin)
    let view3ViewTopAnchorConstraint = view3View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view3ViewTopMargin)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(equalTo: view3View.trailingAnchor, constant: view3ViewTrailingMargin + view2ViewLeadingMargin)
    let view2ViewTopAnchorConstraint = view2View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view2ViewTopMargin)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 60)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 60)
    let view3ViewHeightAnchorConstraint = view3View.heightAnchor.constraint(equalToConstant: 120)
    let view3ViewWidthAnchorConstraint = view3View.widthAnchor.constraint(equalToConstant: 100)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 180)
    let view2ViewWidthAnchorConstraint = view2View.widthAnchor.constraint(equalToConstant: 100)
    view1ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view3ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view2ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      view1ViewHeightAnchorParentConstraint,
      view3ViewHeightAnchorParentConstraint,
      view2ViewHeightAnchorParentConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      view3ViewHeightAnchorConstraint,
      view3ViewWidthAnchorConstraint,
      view2ViewHeightAnchorConstraint,
      view2ViewWidthAnchorConstraint
    ])

    self.view1ViewHeightAnchorParentConstraint = view1ViewHeightAnchorParentConstraint
    self.view3ViewHeightAnchorParentConstraint = view3ViewHeightAnchorParentConstraint
    self.view2ViewHeightAnchorParentConstraint = view2ViewHeightAnchorParentConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view3ViewLeadingAnchorConstraint = view3ViewLeadingAnchorConstraint
    self.view3ViewTopAnchorConstraint = view3ViewTopAnchorConstraint
    self.view2ViewLeadingAnchorConstraint = view2ViewLeadingAnchorConstraint
    self.view2ViewTopAnchorConstraint = view2ViewTopAnchorConstraint
    self.view1ViewHeightAnchorConstraint = view1ViewHeightAnchorConstraint
    self.view1ViewWidthAnchorConstraint = view1ViewWidthAnchorConstraint
    self.view3ViewHeightAnchorConstraint = view3ViewHeightAnchorConstraint
    self.view3ViewWidthAnchorConstraint = view3ViewWidthAnchorConstraint
    self.view2ViewHeightAnchorConstraint = view2ViewHeightAnchorConstraint
    self.view2ViewWidthAnchorConstraint = view2ViewWidthAnchorConstraint

    // For debugging
    view1ViewHeightAnchorParentConstraint.identifier = "view1ViewHeightAnchorParentConstraint"
    view3ViewHeightAnchorParentConstraint.identifier = "view3ViewHeightAnchorParentConstraint"
    view2ViewHeightAnchorParentConstraint.identifier = "view2ViewHeightAnchorParentConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view3ViewLeadingAnchorConstraint.identifier = "view3ViewLeadingAnchorConstraint"
    view3ViewTopAnchorConstraint.identifier = "view3ViewTopAnchorConstraint"
    view2ViewLeadingAnchorConstraint.identifier = "view2ViewLeadingAnchorConstraint"
    view2ViewTopAnchorConstraint.identifier = "view2ViewTopAnchorConstraint"
    view1ViewHeightAnchorConstraint.identifier = "view1ViewHeightAnchorConstraint"
    view1ViewWidthAnchorConstraint.identifier = "view1ViewWidthAnchorConstraint"
    view3ViewHeightAnchorConstraint.identifier = "view3ViewHeightAnchorConstraint"
    view3ViewWidthAnchorConstraint.identifier = "view3ViewWidthAnchorConstraint"
    view2ViewHeightAnchorConstraint.identifier = "view2ViewHeightAnchorConstraint"
    view2ViewWidthAnchorConstraint.identifier = "view2ViewWidthAnchorConstraint"
  }

  private func update() {}
}
