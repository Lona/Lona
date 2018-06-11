import AppKit
import Foundation

// MARK: - ComponentPreviewCard

public class ComponentPreviewCard: NSBox {

  // MARK: Lifecycle

  public init(componentName: String, selected: Bool) {
    self.componentName = componentName
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(componentName: "", selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var componentName: String { didSet { update() } }
  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var previewView = NSBox()
  private var componentPreviewView = ComponentPreview()
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var componentNameView = NSTextField(labelWithString: "")

  private var componentNameViewTextStyle = TextStyles.large

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var previewViewTopMargin: CGFloat = 0
  private var previewViewTrailingMargin: CGFloat = 0
  private var previewViewBottomMargin: CGFloat = 0
  private var previewViewLeadingMargin: CGFloat = 0
  private var previewViewTopPadding: CGFloat = 10
  private var previewViewTrailingPadding: CGFloat = 10
  private var previewViewBottomPadding: CGFloat = 10
  private var previewViewLeadingPadding: CGFloat = 10
  private var dividerViewTopMargin: CGFloat = 0
  private var dividerViewTrailingMargin: CGFloat = 0
  private var dividerViewBottomMargin: CGFloat = 0
  private var dividerViewLeadingMargin: CGFloat = 0
  private var detailsViewTopMargin: CGFloat = 0
  private var detailsViewTrailingMargin: CGFloat = 0
  private var detailsViewBottomMargin: CGFloat = 0
  private var detailsViewLeadingMargin: CGFloat = 0
  private var detailsViewTopPadding: CGFloat = 16
  private var detailsViewTrailingPadding: CGFloat = 20
  private var detailsViewBottomPadding: CGFloat = 16
  private var detailsViewLeadingPadding: CGFloat = 20
  private var componentPreviewViewTopMargin: CGFloat = 0
  private var componentPreviewViewTrailingMargin: CGFloat = 0
  private var componentPreviewViewBottomMargin: CGFloat = 0
  private var componentPreviewViewLeadingMargin: CGFloat = 0
  private var componentNameViewTopMargin: CGFloat = 0
  private var componentNameViewTrailingMargin: CGFloat = 0
  private var componentNameViewBottomMargin: CGFloat = 0
  private var componentNameViewLeadingMargin: CGFloat = 0

  private var previewViewTopAnchorConstraint: NSLayoutConstraint?
  private var previewViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var previewViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTopAnchorConstraint: NSLayoutConstraint?
  private var detailsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewViewTopAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewViewBottomAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var componentNameViewTopAnchorConstraint: NSLayoutConstraint?
  private var componentNameViewBottomAnchorConstraint: NSLayoutConstraint?
  private var componentNameViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var componentNameViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var componentNameViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    previewView.boxType = .custom
    previewView.borderType = .noBorder
    previewView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    detailsView.boxType = .custom
    detailsView.borderType = .noBorder
    detailsView.contentViewMargins = .zero
    componentNameView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    previewView.addSubview(componentPreviewView)
    detailsView.addSubview(componentNameView)

    fillColor = Colors.white
    cornerRadius = 4
    borderWidth = 1
    borderColor = Colors.grey300
    componentNameView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    componentPreviewView.translatesAutoresizingMaskIntoConstraints = false
    componentNameView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + previewViewTopMargin)
    let previewViewLeadingAnchorConstraint = previewView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + previewViewLeadingMargin)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + previewViewTrailingMargin))
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: previewViewBottomMargin + dividerViewTopMargin)
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + dividerViewLeadingMargin)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + dividerViewTrailingMargin))
    let detailsViewBottomAnchorConstraint = detailsView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + detailsViewBottomMargin))
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: dividerView.bottomAnchor, constant: dividerViewBottomMargin + detailsViewTopMargin)
    let detailsViewLeadingAnchorConstraint = detailsView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + detailsViewLeadingMargin)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + detailsViewTrailingMargin))
    let componentPreviewViewTopAnchorConstraint = componentPreviewView
      .topAnchor
      .constraint(equalTo: previewView.topAnchor, constant: previewViewTopPadding + componentPreviewViewTopMargin)
    let componentPreviewViewBottomAnchorConstraint = componentPreviewView
      .bottomAnchor
      .constraint(
        equalTo: previewView.bottomAnchor,
        constant: -(previewViewBottomPadding + componentPreviewViewBottomMargin))
    let componentPreviewViewLeadingAnchorConstraint = componentPreviewView
      .leadingAnchor
      .constraint(
        equalTo: previewView.leadingAnchor,
        constant: previewViewLeadingPadding + componentPreviewViewLeadingMargin)
    let componentPreviewViewTrailingAnchorConstraint = componentPreviewView
      .trailingAnchor
      .constraint(
        equalTo: previewView.trailingAnchor,
        constant: -(previewViewTrailingPadding + componentPreviewViewTrailingMargin))
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let componentNameViewTopAnchorConstraint = componentNameView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: detailsViewTopPadding + componentNameViewTopMargin)
    let componentNameViewBottomAnchorConstraint = componentNameView
      .bottomAnchor
      .constraint(
        equalTo: detailsView.bottomAnchor,
        constant: -(detailsViewBottomPadding + componentNameViewBottomMargin))
    let componentNameViewLeadingAnchorConstraint = componentNameView
      .leadingAnchor
      .constraint(
        equalTo: detailsView.leadingAnchor,
        constant: detailsViewLeadingPadding + componentNameViewLeadingMargin)
    let componentNameViewTrailingAnchorConstraint = componentNameView
      .trailingAnchor
      .constraint(
        equalTo: detailsView.trailingAnchor,
        constant: -(detailsViewTrailingPadding + componentNameViewTrailingMargin))
    let componentNameViewHeightAnchorConstraint = componentNameView.heightAnchor.constraint(equalToConstant: 18)

    NSLayoutConstraint.activate([
      previewViewTopAnchorConstraint,
      previewViewLeadingAnchorConstraint,
      previewViewTrailingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      detailsViewBottomAnchorConstraint,
      detailsViewTopAnchorConstraint,
      detailsViewLeadingAnchorConstraint,
      detailsViewTrailingAnchorConstraint,
      componentPreviewViewTopAnchorConstraint,
      componentPreviewViewBottomAnchorConstraint,
      componentPreviewViewLeadingAnchorConstraint,
      componentPreviewViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      componentNameViewTopAnchorConstraint,
      componentNameViewBottomAnchorConstraint,
      componentNameViewLeadingAnchorConstraint,
      componentNameViewTrailingAnchorConstraint,
      componentNameViewHeightAnchorConstraint
    ])

    self.previewViewTopAnchorConstraint = previewViewTopAnchorConstraint
    self.previewViewLeadingAnchorConstraint = previewViewLeadingAnchorConstraint
    self.previewViewTrailingAnchorConstraint = previewViewTrailingAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.detailsViewBottomAnchorConstraint = detailsViewBottomAnchorConstraint
    self.detailsViewTopAnchorConstraint = detailsViewTopAnchorConstraint
    self.detailsViewLeadingAnchorConstraint = detailsViewLeadingAnchorConstraint
    self.detailsViewTrailingAnchorConstraint = detailsViewTrailingAnchorConstraint
    self.componentPreviewViewTopAnchorConstraint = componentPreviewViewTopAnchorConstraint
    self.componentPreviewViewBottomAnchorConstraint = componentPreviewViewBottomAnchorConstraint
    self.componentPreviewViewLeadingAnchorConstraint = componentPreviewViewLeadingAnchorConstraint
    self.componentPreviewViewTrailingAnchorConstraint = componentPreviewViewTrailingAnchorConstraint
    self.dividerViewHeightAnchorConstraint = dividerViewHeightAnchorConstraint
    self.componentNameViewTopAnchorConstraint = componentNameViewTopAnchorConstraint
    self.componentNameViewBottomAnchorConstraint = componentNameViewBottomAnchorConstraint
    self.componentNameViewLeadingAnchorConstraint = componentNameViewLeadingAnchorConstraint
    self.componentNameViewTrailingAnchorConstraint = componentNameViewTrailingAnchorConstraint
    self.componentNameViewHeightAnchorConstraint = componentNameViewHeightAnchorConstraint

    // For debugging
    previewViewTopAnchorConstraint.identifier = "previewViewTopAnchorConstraint"
    previewViewLeadingAnchorConstraint.identifier = "previewViewLeadingAnchorConstraint"
    previewViewTrailingAnchorConstraint.identifier = "previewViewTrailingAnchorConstraint"
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewTrailingAnchorConstraint.identifier = "dividerViewTrailingAnchorConstraint"
    detailsViewBottomAnchorConstraint.identifier = "detailsViewBottomAnchorConstraint"
    detailsViewTopAnchorConstraint.identifier = "detailsViewTopAnchorConstraint"
    detailsViewLeadingAnchorConstraint.identifier = "detailsViewLeadingAnchorConstraint"
    detailsViewTrailingAnchorConstraint.identifier = "detailsViewTrailingAnchorConstraint"
    componentPreviewViewTopAnchorConstraint.identifier = "componentPreviewViewTopAnchorConstraint"
    componentPreviewViewBottomAnchorConstraint.identifier = "componentPreviewViewBottomAnchorConstraint"
    componentPreviewViewLeadingAnchorConstraint.identifier = "componentPreviewViewLeadingAnchorConstraint"
    componentPreviewViewTrailingAnchorConstraint.identifier = "componentPreviewViewTrailingAnchorConstraint"
    dividerViewHeightAnchorConstraint.identifier = "dividerViewHeightAnchorConstraint"
    componentNameViewTopAnchorConstraint.identifier = "componentNameViewTopAnchorConstraint"
    componentNameViewBottomAnchorConstraint.identifier = "componentNameViewBottomAnchorConstraint"
    componentNameViewLeadingAnchorConstraint.identifier = "componentNameViewLeadingAnchorConstraint"
    componentNameViewTrailingAnchorConstraint.identifier = "componentNameViewTrailingAnchorConstraint"
    componentNameViewHeightAnchorConstraint.identifier = "componentNameViewHeightAnchorConstraint"
  }

  private func update() {
    componentNameViewTextStyle = TextStyles.large
    componentNameView.attributedStringValue =
      componentNameViewTextStyle.apply(to: componentNameView.attributedStringValue)
    detailsView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    dividerView.fillColor = Colors.grey300
    previewView.fillColor = Colors.grey100
    componentNameView.attributedStringValue = componentNameViewTextStyle.apply(to: componentName)
    componentPreviewView.componentName = componentName
    if selected {
      previewView.fillColor = Colors.lightblue600
      detailsView.fillColor = Colors.lightblue600
      dividerView.fillColor = Colors.lightblue700
      componentNameViewTextStyle = TextStyles.largeInverse
      componentNameView.attributedStringValue =
        componentNameViewTextStyle.apply(to: componentNameView.attributedStringValue)
    }
  }
}
