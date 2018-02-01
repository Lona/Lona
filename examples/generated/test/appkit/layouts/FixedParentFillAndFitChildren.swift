import AppKit
import Foundation

// MARK: - FixedParentFillAndFitChildren

public class FixedParentFillAndFitChildren: NSBox {

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
  private var view4View = NSBox()
  private var view5View = NSBox()
  private var view2View = NSBox()
  private var view3View = NSBox()

  private var topPadding: CGFloat = 24
  private var trailingPadding: CGFloat = 24
  private var bottomPadding: CGFloat = 24
  private var leadingPadding: CGFloat = 24
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0
  private var view1ViewTopPadding: CGFloat = 24
  private var view1ViewTrailingPadding: CGFloat = 24
  private var view1ViewBottomPadding: CGFloat = 24
  private var view1ViewLeadingPadding: CGFloat = 24
  private var view2ViewTopMargin: CGFloat = 0
  private var view2ViewTrailingMargin: CGFloat = 0
  private var view2ViewBottomMargin: CGFloat = 0
  private var view2ViewLeadingMargin: CGFloat = 0
  private var view3ViewTopMargin: CGFloat = 0
  private var view3ViewTrailingMargin: CGFloat = 0
  private var view3ViewBottomMargin: CGFloat = 0
  private var view3ViewLeadingMargin: CGFloat = 0
  private var view4ViewTopMargin: CGFloat = 0
  private var view4ViewTrailingMargin: CGFloat = 0
  private var view4ViewBottomMargin: CGFloat = 0
  private var view4ViewLeadingMargin: CGFloat = 0
  private var view5ViewTopMargin: CGFloat = 0
  private var view5ViewTrailingMargin: CGFloat = 0
  private var view5ViewBottomMargin: CGFloat = 0
  private var view5ViewLeadingMargin: CGFloat = 12

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var view2ViewHeightAnchorSiblingConstraint0: NSLayoutConstraint?
  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view3ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var view3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view3ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view4ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view4ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view4ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var view5ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view5ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view5ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var view4ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view4ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var view5ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view5ViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    view4View.boxType = .custom
    view4View.borderType = .noBorder
    view4View.contentViewMargins = .zero
    view5View.boxType = .custom
    view5View.borderType = .noBorder
    view5View.contentViewMargins = .zero

    addSubview(view1View)
    addSubview(view2View)
    addSubview(view3View)
    view1View.addSubview(view4View)
    view1View.addSubview(view5View)

    view1View.fillColor = Colors.red50
    view4View.fillColor = Colors.red200
    view5View.fillColor = Colors.deeporange200
    view2View.fillColor = Colors.indigo100
    view3View.fillColor = Colors.teal100
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    view5View.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 600)
    let view2ViewHeightAnchorSiblingConstraint0 = view2View
      .heightAnchor
      .constraint(equalTo: view3View.heightAnchor, constant: 0)
    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTrailingAnchorConstraint = view1View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view1ViewTrailingMargin))
    let view2ViewTopAnchorConstraint = view2View
      .topAnchor
      .constraint(equalTo: view1View.bottomAnchor, constant: view1ViewBottomMargin + view2ViewTopMargin)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view2ViewLeadingMargin)
    let view2ViewTrailingAnchorConstraint = view2View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view2ViewTrailingMargin))
    let view3ViewBottomAnchorConstraint = view3View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + view3ViewBottomMargin))
    let view3ViewTopAnchorConstraint = view3View
      .topAnchor
      .constraint(equalTo: view2View.bottomAnchor, constant: view2ViewBottomMargin + view3ViewTopMargin)
    let view3ViewLeadingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view3ViewLeadingMargin)
    let view3ViewTrailingAnchorConstraint = view3View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view3ViewTrailingMargin))
    let view4ViewLeadingAnchorConstraint = view4View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor, constant: view1ViewLeadingPadding + view4ViewLeadingMargin)
    let view4ViewTopAnchorConstraint = view4View
      .topAnchor
      .constraint(equalTo: view1View.topAnchor, constant: view1ViewTopPadding + view4ViewTopMargin)
    let view4ViewHeightAnchorParentConstraint = view4View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: view1View.heightAnchor,
        constant: -(view1ViewTopPadding + view4ViewTopMargin + view1ViewBottomPadding + view4ViewBottomMargin))
    let view5ViewLeadingAnchorConstraint = view5View
      .leadingAnchor
      .constraint(equalTo: view4View.trailingAnchor, constant: view4ViewTrailingMargin + view5ViewLeadingMargin)
    let view5ViewTopAnchorConstraint = view5View
      .topAnchor
      .constraint(equalTo: view1View.topAnchor, constant: view1ViewTopPadding + view5ViewTopMargin)
    let view5ViewHeightAnchorParentConstraint = view5View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: view1View.heightAnchor,
        constant: -(view1ViewTopPadding + view5ViewTopMargin + view1ViewBottomPadding + view5ViewBottomMargin))
    let view4ViewHeightAnchorConstraint = view4View.heightAnchor.constraint(equalToConstant: 100)
    let view4ViewWidthAnchorConstraint = view4View.widthAnchor.constraint(equalToConstant: 60)
    let view5ViewHeightAnchorConstraint = view5View.heightAnchor.constraint(equalToConstant: 60)
    let view5ViewWidthAnchorConstraint = view5View.widthAnchor.constraint(equalToConstant: 60)
    view4ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view5ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      view2ViewHeightAnchorSiblingConstraint0,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      view3ViewBottomAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTrailingAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewHeightAnchorParentConstraint,
      view5ViewLeadingAnchorConstraint,
      view5ViewTopAnchorConstraint,
      view5ViewHeightAnchorParentConstraint,
      view4ViewHeightAnchorConstraint,
      view4ViewWidthAnchorConstraint,
      view5ViewHeightAnchorConstraint,
      view5ViewWidthAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.view2ViewHeightAnchorSiblingConstraint0 = view2ViewHeightAnchorSiblingConstraint0
    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTrailingAnchorConstraint = view1ViewTrailingAnchorConstraint
    self.view2ViewTopAnchorConstraint = view2ViewTopAnchorConstraint
    self.view2ViewLeadingAnchorConstraint = view2ViewLeadingAnchorConstraint
    self.view2ViewTrailingAnchorConstraint = view2ViewTrailingAnchorConstraint
    self.view3ViewBottomAnchorConstraint = view3ViewBottomAnchorConstraint
    self.view3ViewTopAnchorConstraint = view3ViewTopAnchorConstraint
    self.view3ViewLeadingAnchorConstraint = view3ViewLeadingAnchorConstraint
    self.view3ViewTrailingAnchorConstraint = view3ViewTrailingAnchorConstraint
    self.view4ViewLeadingAnchorConstraint = view4ViewLeadingAnchorConstraint
    self.view4ViewTopAnchorConstraint = view4ViewTopAnchorConstraint
    self.view4ViewHeightAnchorParentConstraint = view4ViewHeightAnchorParentConstraint
    self.view5ViewLeadingAnchorConstraint = view5ViewLeadingAnchorConstraint
    self.view5ViewTopAnchorConstraint = view5ViewTopAnchorConstraint
    self.view5ViewHeightAnchorParentConstraint = view5ViewHeightAnchorParentConstraint
    self.view4ViewHeightAnchorConstraint = view4ViewHeightAnchorConstraint
    self.view4ViewWidthAnchorConstraint = view4ViewWidthAnchorConstraint
    self.view5ViewHeightAnchorConstraint = view5ViewHeightAnchorConstraint
    self.view5ViewWidthAnchorConstraint = view5ViewWidthAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    view2ViewHeightAnchorSiblingConstraint0.identifier = "view2ViewHeightAnchorSiblingConstraint0"
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTrailingAnchorConstraint.identifier = "view1ViewTrailingAnchorConstraint"
    view2ViewTopAnchorConstraint.identifier = "view2ViewTopAnchorConstraint"
    view2ViewLeadingAnchorConstraint.identifier = "view2ViewLeadingAnchorConstraint"
    view2ViewTrailingAnchorConstraint.identifier = "view2ViewTrailingAnchorConstraint"
    view3ViewBottomAnchorConstraint.identifier = "view3ViewBottomAnchorConstraint"
    view3ViewTopAnchorConstraint.identifier = "view3ViewTopAnchorConstraint"
    view3ViewLeadingAnchorConstraint.identifier = "view3ViewLeadingAnchorConstraint"
    view3ViewTrailingAnchorConstraint.identifier = "view3ViewTrailingAnchorConstraint"
    view4ViewLeadingAnchorConstraint.identifier = "view4ViewLeadingAnchorConstraint"
    view4ViewTopAnchorConstraint.identifier = "view4ViewTopAnchorConstraint"
    view4ViewHeightAnchorParentConstraint.identifier = "view4ViewHeightAnchorParentConstraint"
    view5ViewLeadingAnchorConstraint.identifier = "view5ViewLeadingAnchorConstraint"
    view5ViewTopAnchorConstraint.identifier = "view5ViewTopAnchorConstraint"
    view5ViewHeightAnchorParentConstraint.identifier = "view5ViewHeightAnchorParentConstraint"
    view4ViewHeightAnchorConstraint.identifier = "view4ViewHeightAnchorConstraint"
    view4ViewWidthAnchorConstraint.identifier = "view4ViewWidthAnchorConstraint"
    view5ViewHeightAnchorConstraint.identifier = "view5ViewHeightAnchorConstraint"
    view5ViewWidthAnchorConstraint.identifier = "view5ViewWidthAnchorConstraint"
  }

  private func update() {}
}
