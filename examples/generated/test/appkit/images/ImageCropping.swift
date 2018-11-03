import AppKit
import Foundation

// MARK: - ImageCropping

public class ImageCropping: NSBox {

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

  private var aspectFitView = NSImageView()
  private var aspectFillView = NSImageView()
  private var stretchFillView = NSImageView()
  private var fixedAspectFillView = NSImageView()
  private var fixedStretchView = NSImageView()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(aspectFitView)
    addSubview(aspectFillView)
    addSubview(stretchFillView)
    addSubview(fixedAspectFillView)
    addSubview(fixedStretchView)

    aspectFitView.image = #imageLiteral(resourceName: "icon_128x128")
    aspectFitView.resizeMode = "contain"
    aspectFillView.image = #imageLiteral(resourceName: "icon_128x128")
    stretchFillView.image = #imageLiteral(resourceName: "icon_128x128")
    stretchFillView.resizeMode = "stretch"
    fixedAspectFillView.image = #imageLiteral(resourceName: "icon_128x128")
    fixedStretchView.image = #imageLiteral(resourceName: "icon_128x128")
    fixedStretchView.resizeMode = "stretch"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    aspectFitView.translatesAutoresizingMaskIntoConstraints = false
    aspectFillView.translatesAutoresizingMaskIntoConstraints = false
    stretchFillView.translatesAutoresizingMaskIntoConstraints = false
    fixedAspectFillView.translatesAutoresizingMaskIntoConstraints = false
    fixedStretchView.translatesAutoresizingMaskIntoConstraints = false

    let aspectFitViewTopAnchorConstraint = aspectFitView.topAnchor.constraint(equalTo: topAnchor)
    let aspectFitViewLeadingAnchorConstraint = aspectFitView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let aspectFitViewTrailingAnchorConstraint = aspectFitView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let aspectFillViewTopAnchorConstraint = aspectFillView.topAnchor.constraint(equalTo: aspectFitView.bottomAnchor)
    let aspectFillViewLeadingAnchorConstraint = aspectFillView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let aspectFillViewTrailingAnchorConstraint = aspectFillView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let stretchFillViewTopAnchorConstraint = stretchFillView.topAnchor.constraint(equalTo: aspectFillView.bottomAnchor)
    let stretchFillViewLeadingAnchorConstraint = stretchFillView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let stretchFillViewTrailingAnchorConstraint = stretchFillView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let fixedAspectFillViewTopAnchorConstraint = fixedAspectFillView
      .topAnchor
      .constraint(equalTo: stretchFillView.bottomAnchor)
    let fixedAspectFillViewLeadingAnchorConstraint = fixedAspectFillView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fixedStretchViewBottomAnchorConstraint = fixedStretchView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let fixedStretchViewTopAnchorConstraint = fixedStretchView
      .topAnchor
      .constraint(equalTo: fixedAspectFillView.bottomAnchor)
    let fixedStretchViewLeadingAnchorConstraint = fixedStretchView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let aspectFitViewHeightAnchorConstraint = aspectFitView.heightAnchor.constraint(equalToConstant: 100)
    let aspectFillViewHeightAnchorConstraint = aspectFillView.heightAnchor.constraint(equalToConstant: 100)
    let stretchFillViewHeightAnchorConstraint = stretchFillView.heightAnchor.constraint(equalToConstant: 100)
    let fixedAspectFillViewHeightAnchorConstraint = fixedAspectFillView.heightAnchor.constraint(equalToConstant: 100)
    let fixedAspectFillViewWidthAnchorConstraint = fixedAspectFillView.widthAnchor.constraint(equalToConstant: 200)
    let fixedStretchViewHeightAnchorConstraint = fixedStretchView.heightAnchor.constraint(equalToConstant: 100)
    let fixedStretchViewWidthAnchorConstraint = fixedStretchView.widthAnchor.constraint(equalToConstant: 200)

    NSLayoutConstraint.activate([
      aspectFitViewTopAnchorConstraint,
      aspectFitViewLeadingAnchorConstraint,
      aspectFitViewTrailingAnchorConstraint,
      aspectFillViewTopAnchorConstraint,
      aspectFillViewLeadingAnchorConstraint,
      aspectFillViewTrailingAnchorConstraint,
      stretchFillViewTopAnchorConstraint,
      stretchFillViewLeadingAnchorConstraint,
      stretchFillViewTrailingAnchorConstraint,
      fixedAspectFillViewTopAnchorConstraint,
      fixedAspectFillViewLeadingAnchorConstraint,
      fixedStretchViewBottomAnchorConstraint,
      fixedStretchViewTopAnchorConstraint,
      fixedStretchViewLeadingAnchorConstraint,
      aspectFitViewHeightAnchorConstraint,
      aspectFillViewHeightAnchorConstraint,
      stretchFillViewHeightAnchorConstraint,
      fixedAspectFillViewHeightAnchorConstraint,
      fixedAspectFillViewWidthAnchorConstraint,
      fixedStretchViewHeightAnchorConstraint,
      fixedStretchViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}
