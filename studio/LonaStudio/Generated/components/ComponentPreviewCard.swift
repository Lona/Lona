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

    let previewViewTopAnchorConstraint = previewView.topAnchor.constraint(equalTo: topAnchor, constant: 1)
    let previewViewLeadingAnchorConstraint = previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: previewView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let detailsViewBottomAnchorConstraint = detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    let detailsViewTopAnchorConstraint = detailsView.topAnchor.constraint(equalTo: dividerView.bottomAnchor)
    let detailsViewLeadingAnchorConstraint = detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let componentPreviewViewTopAnchorConstraint = componentPreviewView
      .topAnchor
      .constraint(equalTo: previewView.topAnchor, constant: 10)
    let componentPreviewViewBottomAnchorConstraint = componentPreviewView
      .bottomAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: -10)
    let componentPreviewViewLeadingAnchorConstraint = componentPreviewView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: 10)
    let componentPreviewViewTrailingAnchorConstraint = componentPreviewView
      .trailingAnchor
      .constraint(equalTo: previewView.trailingAnchor, constant: -10)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let componentNameViewTopAnchorConstraint = componentNameView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: 16)
    let componentNameViewBottomAnchorConstraint = componentNameView
      .bottomAnchor
      .constraint(equalTo: detailsView.bottomAnchor, constant: -16)
    let componentNameViewLeadingAnchorConstraint = componentNameView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor, constant: 20)
    let componentNameViewTrailingAnchorConstraint = componentNameView
      .trailingAnchor
      .constraint(equalTo: detailsView.trailingAnchor, constant: -20)
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
