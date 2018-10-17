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

    colorPreviewCardView.color = Colors.red500
    colorPreviewCardView.colorCode = "#ff0000"
    colorPreviewCardView.colorName = "Red"
    colorPreviewCardView.selected = true
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

    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor, constant: 36)
    let spacer1ViewLeadingAnchorConstraint = spacer1View.leadingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let spacer1ViewTopAnchorConstraint = spacer1View.topAnchor.constraint(equalTo: topAnchor, constant: 36)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: spacer1View.trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: topAnchor, constant: 36)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 130)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 90)
    let colorPreviewCardViewTopAnchorConstraint = colorPreviewCardView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor)
    let colorPreviewCardViewBottomAnchorConstraint = colorPreviewCardView
      .bottomAnchor
      .constraint(equalTo: view1View.bottomAnchor)
    let colorPreviewCardViewLeadingAnchorConstraint = colorPreviewCardView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let colorPreviewCardViewTrailingAnchorConstraint = colorPreviewCardView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor)
    let spacer1ViewHeightAnchorConstraint = spacer1View.heightAnchor.constraint(equalToConstant: 0)
    let spacer1ViewWidthAnchorConstraint = spacer1View.widthAnchor.constraint(equalToConstant: 20)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 130)
    let view2ViewWidthAnchorConstraint = view2View.widthAnchor.constraint(equalToConstant: 90)
    let colorPreviewCard2ViewTopAnchorConstraint = colorPreviewCard2View
      .topAnchor
      .constraint(equalTo: view2View.topAnchor)
    let colorPreviewCard2ViewBottomAnchorConstraint = colorPreviewCard2View
      .bottomAnchor
      .constraint(equalTo: view2View.bottomAnchor)
    let colorPreviewCard2ViewLeadingAnchorConstraint = colorPreviewCard2View
      .leadingAnchor
      .constraint(equalTo: view2View.leadingAnchor)
    let colorPreviewCard2ViewTrailingAnchorConstraint = colorPreviewCard2View
      .trailingAnchor
      .constraint(equalTo: view2View.trailingAnchor)

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
  }

  private func update() {}
}
