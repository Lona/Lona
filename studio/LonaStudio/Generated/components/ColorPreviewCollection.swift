import AppKit
import Foundation

// MARK: - ColorPreviewCollection

public class ColorPreviewCollection: NSBox {

  // MARK: Lifecycle

  public init(
    onSelectColor: ColorHandler,
    onChangeColor: ColorHandler,
    onDeleteColor: ColorHandler,
    onMoveColor: ItemMoveHandler,
    colors: ColorList)
  {
    self.onSelectColor = onSelectColor
    self.onChangeColor = onChangeColor
    self.onDeleteColor = onDeleteColor
    self.onMoveColor = onMoveColor
    self.colors = colors

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(onSelectColor: nil, onChangeColor: nil, onDeleteColor: nil, onMoveColor: nil, colors: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectColor: ColorHandler { didSet { update() } }
  public var onChangeColor: ColorHandler { didSet { update() } }
  public var onDeleteColor: ColorHandler { didSet { update() } }
  public var onMoveColor: ItemMoveHandler { didSet { update() } }
  public var colors: ColorList { didSet { update() } }

  // MARK: Private

  private var view1View = NSBox()
  private var colorPreviewCardView = ColorPreviewCard()
  private var spacer1View = NSBox()
  private var view2View = NSBox()
  private var colorPreviewCard2View = ColorPreviewCard()

  private var topPadding: CGFloat = 36
  private var trailingPadding: CGFloat = 48
  private var bottomPadding: CGFloat = 36
  private var leadingPadding: CGFloat = 48
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0
  private var view1ViewTopPadding: CGFloat = 0
  private var view1ViewTrailingPadding: CGFloat = 0
  private var view1ViewBottomPadding: CGFloat = 0
  private var view1ViewLeadingPadding: CGFloat = 0
  private var spacer1ViewTopMargin: CGFloat = 0
  private var spacer1ViewTrailingMargin: CGFloat = 0
  private var spacer1ViewBottomMargin: CGFloat = 0
  private var spacer1ViewLeadingMargin: CGFloat = 0
  private var view2ViewTopMargin: CGFloat = 0
  private var view2ViewTrailingMargin: CGFloat = 0
  private var view2ViewBottomMargin: CGFloat = 0
  private var view2ViewLeadingMargin: CGFloat = 0
  private var view2ViewTopPadding: CGFloat = 0
  private var view2ViewTrailingPadding: CGFloat = 0
  private var view2ViewBottomPadding: CGFloat = 0
  private var view2ViewLeadingPadding: CGFloat = 0
  private var colorPreviewCardViewTopMargin: CGFloat = 0
  private var colorPreviewCardViewTrailingMargin: CGFloat = 0
  private var colorPreviewCardViewBottomMargin: CGFloat = 0
  private var colorPreviewCardViewLeadingMargin: CGFloat = 0
  private var colorPreviewCard2ViewTopMargin: CGFloat = 0
  private var colorPreviewCard2ViewTrailingMargin: CGFloat = 0
  private var colorPreviewCard2ViewBottomMargin: CGFloat = 0
  private var colorPreviewCard2ViewLeadingMargin: CGFloat = 0

  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view1ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCardViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCardViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCardViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCardViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var view2ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var view2ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCard2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCard2ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCard2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCard2ViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    spacer1View.boxType = .custom
    spacer1View.borderType = .noBorder
    spacer1View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero

    addSubview(view1View)
    addSubview(spacer1View)
    addSubview(view2View)
    view1View.addSubview(colorPreviewCardView)
    view2View.addSubview(colorPreviewCard2View)

    fillColor = Colors.pink50
    view1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    colorPreviewCardView.color = Colors.red500
    colorPreviewCardView.colorCode = "#ff0000"
    colorPreviewCardView.colorName = "Red"
    colorPreviewCardView.selected = false
    view2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    colorPreviewCard2View.color = Colors.black
    colorPreviewCard2View.colorCode = "Text"
    colorPreviewCard2View.colorName = "Text"
    colorPreviewCard2View.selected = false
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    spacer1View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    colorPreviewCardView.translatesAutoresizingMaskIntoConstraints = false
    colorPreviewCard2View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view1ViewTopMargin)
    let spacer1ViewLeadingAnchorConstraint = spacer1View
      .leadingAnchor
      .constraint(equalTo: view1View.trailingAnchor, constant: view1ViewTrailingMargin + spacer1ViewLeadingMargin)
    let spacer1ViewTopAnchorConstraint = spacer1View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + spacer1ViewTopMargin)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(equalTo: spacer1View.trailingAnchor, constant: spacer1ViewTrailingMargin + view2ViewLeadingMargin)
    let view2ViewTopAnchorConstraint = view2View
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + view2ViewTopMargin)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 140)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 120)
    let colorPreviewCardViewTopAnchorConstraint = colorPreviewCardView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor, constant: view1ViewTopPadding + colorPreviewCardViewTopMargin)
    let colorPreviewCardViewBottomAnchorConstraint = colorPreviewCardView
      .bottomAnchor
      .constraint(
        equalTo: view1View.bottomAnchor,
        constant: -(view1ViewBottomPadding + colorPreviewCardViewBottomMargin))
    let colorPreviewCardViewLeadingAnchorConstraint = colorPreviewCardView
      .leadingAnchor
      .constraint(
        equalTo: view1View.leadingAnchor,
        constant: view1ViewLeadingPadding + colorPreviewCardViewLeadingMargin)
    let colorPreviewCardViewTrailingAnchorConstraint = colorPreviewCardView
      .trailingAnchor
      .constraint(
        equalTo: view1View.trailingAnchor,
        constant: -(view1ViewTrailingPadding + colorPreviewCardViewTrailingMargin))
    let spacer1ViewHeightAnchorConstraint = spacer1View.heightAnchor.constraint(equalToConstant: 0)
    let spacer1ViewWidthAnchorConstraint = spacer1View.widthAnchor.constraint(equalToConstant: 20)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 140)
    let view2ViewWidthAnchorConstraint = view2View.widthAnchor.constraint(equalToConstant: 120)
    let colorPreviewCard2ViewTopAnchorConstraint = colorPreviewCard2View
      .topAnchor
      .constraint(equalTo: view2View.topAnchor, constant: view2ViewTopPadding + colorPreviewCard2ViewTopMargin)
    let colorPreviewCard2ViewBottomAnchorConstraint = colorPreviewCard2View
      .bottomAnchor
      .constraint(
        equalTo: view2View.bottomAnchor,
        constant: -(view2ViewBottomPadding + colorPreviewCard2ViewBottomMargin))
    let colorPreviewCard2ViewLeadingAnchorConstraint = colorPreviewCard2View
      .leadingAnchor
      .constraint(
        equalTo: view2View.leadingAnchor,
        constant: view2ViewLeadingPadding + colorPreviewCard2ViewLeadingMargin)
    let colorPreviewCard2ViewTrailingAnchorConstraint = colorPreviewCard2View
      .trailingAnchor
      .constraint(
        equalTo: view2View.trailingAnchor,
        constant: -(view2ViewTrailingPadding + colorPreviewCard2ViewTrailingMargin))

    NSLayoutConstraint.activate([
      view1ViewLeadingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      spacer1ViewLeadingAnchorConstraint,
      spacer1ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      colorPreviewCardViewTopAnchorConstraint,
      colorPreviewCardViewBottomAnchorConstraint,
      colorPreviewCardViewLeadingAnchorConstraint,
      colorPreviewCardViewTrailingAnchorConstraint,
      spacer1ViewHeightAnchorConstraint,
      spacer1ViewWidthAnchorConstraint,
      view2ViewHeightAnchorConstraint,
      view2ViewWidthAnchorConstraint,
      colorPreviewCard2ViewTopAnchorConstraint,
      colorPreviewCard2ViewBottomAnchorConstraint,
      colorPreviewCard2ViewLeadingAnchorConstraint,
      colorPreviewCard2ViewTrailingAnchorConstraint
    ])

    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.spacer1ViewLeadingAnchorConstraint = spacer1ViewLeadingAnchorConstraint
    self.spacer1ViewTopAnchorConstraint = spacer1ViewTopAnchorConstraint
    self.view2ViewLeadingAnchorConstraint = view2ViewLeadingAnchorConstraint
    self.view2ViewTopAnchorConstraint = view2ViewTopAnchorConstraint
    self.view1ViewHeightAnchorConstraint = view1ViewHeightAnchorConstraint
    self.view1ViewWidthAnchorConstraint = view1ViewWidthAnchorConstraint
    self.colorPreviewCardViewTopAnchorConstraint = colorPreviewCardViewTopAnchorConstraint
    self.colorPreviewCardViewBottomAnchorConstraint = colorPreviewCardViewBottomAnchorConstraint
    self.colorPreviewCardViewLeadingAnchorConstraint = colorPreviewCardViewLeadingAnchorConstraint
    self.colorPreviewCardViewTrailingAnchorConstraint = colorPreviewCardViewTrailingAnchorConstraint
    self.spacer1ViewHeightAnchorConstraint = spacer1ViewHeightAnchorConstraint
    self.spacer1ViewWidthAnchorConstraint = spacer1ViewWidthAnchorConstraint
    self.view2ViewHeightAnchorConstraint = view2ViewHeightAnchorConstraint
    self.view2ViewWidthAnchorConstraint = view2ViewWidthAnchorConstraint
    self.colorPreviewCard2ViewTopAnchorConstraint = colorPreviewCard2ViewTopAnchorConstraint
    self.colorPreviewCard2ViewBottomAnchorConstraint = colorPreviewCard2ViewBottomAnchorConstraint
    self.colorPreviewCard2ViewLeadingAnchorConstraint = colorPreviewCard2ViewLeadingAnchorConstraint
    self.colorPreviewCard2ViewTrailingAnchorConstraint = colorPreviewCard2ViewTrailingAnchorConstraint

    // For debugging
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    spacer1ViewLeadingAnchorConstraint.identifier = "spacer1ViewLeadingAnchorConstraint"
    spacer1ViewTopAnchorConstraint.identifier = "spacer1ViewTopAnchorConstraint"
    view2ViewLeadingAnchorConstraint.identifier = "view2ViewLeadingAnchorConstraint"
    view2ViewTopAnchorConstraint.identifier = "view2ViewTopAnchorConstraint"
    view1ViewHeightAnchorConstraint.identifier = "view1ViewHeightAnchorConstraint"
    view1ViewWidthAnchorConstraint.identifier = "view1ViewWidthAnchorConstraint"
    colorPreviewCardViewTopAnchorConstraint.identifier = "colorPreviewCardViewTopAnchorConstraint"
    colorPreviewCardViewBottomAnchorConstraint.identifier = "colorPreviewCardViewBottomAnchorConstraint"
    colorPreviewCardViewLeadingAnchorConstraint.identifier = "colorPreviewCardViewLeadingAnchorConstraint"
    colorPreviewCardViewTrailingAnchorConstraint.identifier = "colorPreviewCardViewTrailingAnchorConstraint"
    spacer1ViewHeightAnchorConstraint.identifier = "spacer1ViewHeightAnchorConstraint"
    spacer1ViewWidthAnchorConstraint.identifier = "spacer1ViewWidthAnchorConstraint"
    view2ViewHeightAnchorConstraint.identifier = "view2ViewHeightAnchorConstraint"
    view2ViewWidthAnchorConstraint.identifier = "view2ViewWidthAnchorConstraint"
    colorPreviewCard2ViewTopAnchorConstraint.identifier = "colorPreviewCard2ViewTopAnchorConstraint"
    colorPreviewCard2ViewBottomAnchorConstraint.identifier = "colorPreviewCard2ViewBottomAnchorConstraint"
    colorPreviewCard2ViewLeadingAnchorConstraint.identifier = "colorPreviewCard2ViewLeadingAnchorConstraint"
    colorPreviewCard2ViewTrailingAnchorConstraint.identifier = "colorPreviewCard2ViewTrailingAnchorConstraint"
  }

  private func update() {}
}
