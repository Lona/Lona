import AppKit
import Foundation

// MARK: - TemplateBrowser

public class TemplateBrowser: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    templateTitles: [String],
    templateDescriptions: [String],
    templateImages: [NSImage],
    selectedTemplateIndex: Int,
    selectedTemplateFiles: [String])
  {
    self
      .init(
        Parameters(
          templateTitles: templateTitles,
          templateDescriptions: templateDescriptions,
          templateImages: templateImages,
          selectedTemplateIndex: selectedTemplateIndex,
          selectedTemplateFiles: selectedTemplateFiles))
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

  public var onClickDone: (() -> Void)? {
    get { return parameters.onClickDone }
    set { parameters.onClickDone = newValue }
  }

  public var onClickCancel: (() -> Void)? {
    get { return parameters.onClickCancel }
    set { parameters.onClickCancel = newValue }
  }

  public var templateTitles: [String] {
    get { return parameters.templateTitles }
    set {
      if parameters.templateTitles != newValue {
        parameters.templateTitles = newValue
      }
    }
  }

  public var templateDescriptions: [String] {
    get { return parameters.templateDescriptions }
    set {
      if parameters.templateDescriptions != newValue {
        parameters.templateDescriptions = newValue
      }
    }
  }

  public var templateImages: [NSImage] {
    get { return parameters.templateImages }
    set {
      if parameters.templateImages != newValue {
        parameters.templateImages = newValue
      }
    }
  }

  public var selectedTemplateIndex: Int {
    get { return parameters.selectedTemplateIndex }
    set {
      if parameters.selectedTemplateIndex != newValue {
        parameters.selectedTemplateIndex = newValue
      }
    }
  }

  public var onChangeSelectedTemplateIndex: ((Int) -> Void)? {
    get { return parameters.onChangeSelectedTemplateIndex }
    set { parameters.onChangeSelectedTemplateIndex = newValue }
  }

  public var selectedTemplateFiles: [String] {
    get { return parameters.selectedTemplateFiles }
    set {
      if parameters.selectedTemplateFiles != newValue {
        parameters.selectedTemplateFiles = newValue
      }
    }
  }

  public var onDoubleClickTemplateIndex: ((Int) -> Void)? {
    get { return parameters.onDoubleClickTemplateIndex }
    set { parameters.onDoubleClickTemplateIndex = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var titleView = LNATextField(labelWithString: "")
  private var dividerView = NSBox()
  private var contentAreaView = NSBox()
  private var templateListContainerView = NSBox()
  private var templateListTitleView = LNATextField(labelWithString: "")
  private var templateListContentView = NSBox()
  private var templatePreviewCollectionView = TemplatePreviewCollection()
  private var vDividerView = NSBox()
  private var fileListContainerView = NSBox()
  private var templateListTitle1View = LNATextField(labelWithString: "")
  private var view1View = NSBox()
  private var templateFileListView = TemplateFileList()
  private var divider5View = NSBox()
  private var view4View = NSBox()
  private var cancelButtonView = Button()
  private var view5View = NSBox()
  private var doneButtonView = Button()

  private var titleViewTextStyle = TextStyles.subtitle
  private var templateListTitleViewTextStyle = TextStyles.sectionTitle
  private var templateListTitle1ViewTextStyle = TextStyles.sectionTitle

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    contentAreaView.boxType = .custom
    contentAreaView.borderType = .noBorder
    contentAreaView.contentViewMargins = .zero
    divider5View.boxType = .custom
    divider5View.borderType = .noBorder
    divider5View.contentViewMargins = .zero
    view4View.boxType = .custom
    view4View.borderType = .noBorder
    view4View.contentViewMargins = .zero
    templateListContainerView.boxType = .custom
    templateListContainerView.borderType = .noBorder
    templateListContainerView.contentViewMargins = .zero
    vDividerView.boxType = .custom
    vDividerView.borderType = .noBorder
    vDividerView.contentViewMargins = .zero
    fileListContainerView.boxType = .custom
    fileListContainerView.borderType = .noBorder
    fileListContainerView.contentViewMargins = .zero
    templateListTitleView.lineBreakMode = .byWordWrapping
    templateListContentView.boxType = .custom
    templateListContentView.borderType = .noBorder
    templateListContentView.contentViewMargins = .zero
    templateListTitle1View.lineBreakMode = .byWordWrapping
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view5View.boxType = .custom
    view5View.borderType = .noBorder
    view5View.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(dividerView)
    addSubview(contentAreaView)
    addSubview(divider5View)
    addSubview(view4View)
    contentAreaView.addSubview(templateListContainerView)
    contentAreaView.addSubview(vDividerView)
    contentAreaView.addSubview(fileListContainerView)
    templateListContainerView.addSubview(templateListTitleView)
    templateListContainerView.addSubview(templateListContentView)
    templateListContentView.addSubview(templatePreviewCollectionView)
    fileListContainerView.addSubview(templateListTitle1View)
    fileListContainerView.addSubview(view1View)
    view1View.addSubview(templateFileListView)
    view4View.addSubview(cancelButtonView)
    view4View.addSubview(view5View)
    view4View.addSubview(doneButtonView)

    fillColor = Colors.windowBackground
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Choose a template")
    titleViewTextStyle = TextStyles.subtitle
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    dividerView.fillColor = Colors.divider
    contentAreaView.fillColor = Colors.headerBackground
    templateListTitleView.attributedStringValue = templateListTitleViewTextStyle.apply(to: "TEMPLATES")
    templateListTitleViewTextStyle = TextStyles.sectionTitle
    templateListTitleView.attributedStringValue =
      templateListTitleViewTextStyle.apply(to: templateListTitleView.attributedStringValue)
    vDividerView.fillColor = Colors.divider
    templateListTitle1View.attributedStringValue = templateListTitle1ViewTextStyle.apply(to: "FILES IN THIS TEMPLATE")
    templateListTitle1ViewTextStyle = TextStyles.sectionTitle
    templateListTitle1View.attributedStringValue =
      templateListTitle1ViewTextStyle.apply(to: templateListTitle1View.attributedStringValue)
    divider5View.fillColor = Colors.divider
    cancelButtonView.titleText = "Cancel"
    doneButtonView.titleText = "OK"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentAreaView.translatesAutoresizingMaskIntoConstraints = false
    divider5View.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    templateListContainerView.translatesAutoresizingMaskIntoConstraints = false
    vDividerView.translatesAutoresizingMaskIntoConstraints = false
    fileListContainerView.translatesAutoresizingMaskIntoConstraints = false
    templateListTitleView.translatesAutoresizingMaskIntoConstraints = false
    templateListContentView.translatesAutoresizingMaskIntoConstraints = false
    templatePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
    templateListTitle1View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    templateFileListView.translatesAutoresizingMaskIntoConstraints = false
    cancelButtonView.translatesAutoresizingMaskIntoConstraints = false
    view5View.translatesAutoresizingMaskIntoConstraints = false
    doneButtonView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 58)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let dividerViewTrailingAnchorConstraint = dividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let contentAreaViewTopAnchorConstraint = contentAreaView.topAnchor.constraint(equalTo: dividerView.bottomAnchor)
    let contentAreaViewLeadingAnchorConstraint = contentAreaView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let contentAreaViewTrailingAnchorConstraint = contentAreaView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let divider5ViewTopAnchorConstraint = divider5View.topAnchor.constraint(equalTo: contentAreaView.bottomAnchor)
    let divider5ViewLeadingAnchorConstraint = divider5View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let divider5ViewTrailingAnchorConstraint = divider5View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view4ViewBottomAnchorConstraint = view4View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view4ViewTopAnchorConstraint = view4View.topAnchor.constraint(equalTo: divider5View.bottomAnchor)
    let view4ViewLeadingAnchorConstraint = view4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view4ViewTrailingAnchorConstraint = view4View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let contentAreaViewHeightAnchorConstraint = contentAreaView.heightAnchor.constraint(equalToConstant: 460)
    let templateListContainerViewLeadingAnchorConstraint = templateListContainerView
      .leadingAnchor
      .constraint(equalTo: contentAreaView.leadingAnchor)
    let templateListContainerViewTopAnchorConstraint = templateListContainerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let templateListContainerViewBottomAnchorConstraint = templateListContainerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor)
    let vDividerViewLeadingAnchorConstraint = vDividerView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.trailingAnchor)
    let vDividerViewTopAnchorConstraint = vDividerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let vDividerViewBottomAnchorConstraint = vDividerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor, constant: -16)
    let fileListContainerViewTrailingAnchorConstraint = fileListContainerView
      .trailingAnchor
      .constraint(equalTo: contentAreaView.trailingAnchor, constant: -40)
    let fileListContainerViewLeadingAnchorConstraint = fileListContainerView
      .leadingAnchor
      .constraint(equalTo: vDividerView.trailingAnchor, constant: 40)
    let fileListContainerViewTopAnchorConstraint = fileListContainerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let fileListContainerViewBottomAnchorConstraint = fileListContainerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor)
    let divider5ViewHeightAnchorConstraint = divider5View.heightAnchor.constraint(equalToConstant: 1)
    let cancelButtonViewHeightAnchorParentConstraint = cancelButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let view5ViewHeightAnchorParentConstraint = view5View
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let doneButtonViewHeightAnchorParentConstraint = doneButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let cancelButtonViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: view4View.leadingAnchor, constant: 24)
    let cancelButtonViewTopAnchorConstraint = cancelButtonView
      .topAnchor
      .constraint(equalTo: view4View.topAnchor, constant: 12)
    let cancelButtonViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let view5ViewLeadingAnchorConstraint = view5View.leadingAnchor.constraint(equalTo: cancelButtonView.trailingAnchor)
    let view5ViewTopAnchorConstraint = view5View.topAnchor.constraint(equalTo: view4View.topAnchor, constant: 12)
    let view5ViewBottomAnchorConstraint = view5View
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(equalTo: view4View.trailingAnchor, constant: -24)
    let doneButtonViewLeadingAnchorConstraint = doneButtonView
      .leadingAnchor
      .constraint(equalTo: view5View.trailingAnchor)
    let doneButtonViewTopAnchorConstraint = doneButtonView
      .topAnchor
      .constraint(equalTo: view4View.topAnchor, constant: 12)
    let doneButtonViewBottomAnchorConstraint = doneButtonView
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let templateListTitleViewTopAnchorConstraint = templateListTitleView
      .topAnchor
      .constraint(equalTo: templateListContainerView.topAnchor, constant: 12)
    let templateListTitleViewLeadingAnchorConstraint = templateListTitleView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.leadingAnchor, constant: 40)
    let templateListTitleViewTrailingAnchorConstraint = templateListTitleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: templateListContainerView.trailingAnchor)
    let templateListContentViewBottomAnchorConstraint = templateListContentView
      .bottomAnchor
      .constraint(equalTo: templateListContainerView.bottomAnchor)
    let templateListContentViewTopAnchorConstraint = templateListContentView
      .topAnchor
      .constraint(equalTo: templateListTitleView.bottomAnchor, constant: 20)
    let templateListContentViewLeadingAnchorConstraint = templateListContentView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.leadingAnchor)
    let templateListContentViewTrailingAnchorConstraint = templateListContentView
      .trailingAnchor
      .constraint(equalTo: templateListContainerView.trailingAnchor)
    let vDividerViewWidthAnchorConstraint = vDividerView.widthAnchor.constraint(equalToConstant: 1)
    let fileListContainerViewWidthAnchorConstraint = fileListContainerView.widthAnchor.constraint(equalToConstant: 321)
    let templateListTitle1ViewTopAnchorConstraint = templateListTitle1View
      .topAnchor
      .constraint(equalTo: fileListContainerView.topAnchor, constant: 12)
    let templateListTitle1ViewLeadingAnchorConstraint = templateListTitle1View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateListTitle1ViewTrailingAnchorConstraint = templateListTitle1View
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let view1ViewBottomAnchorConstraint = view1View
      .bottomAnchor
      .constraint(equalTo: fileListContainerView.bottomAnchor, constant: -16)
    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: templateListTitle1View.bottomAnchor, constant: 20)
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let templatePreviewCollectionViewLeadingAnchorConstraint = templatePreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: templateListContentView.leadingAnchor)
    let templatePreviewCollectionViewTrailingAnchorConstraint = templatePreviewCollectionView
      .trailingAnchor
      .constraint(equalTo: templateListContentView.trailingAnchor)
    let templatePreviewCollectionViewTopAnchorConstraint = templatePreviewCollectionView
      .topAnchor
      .constraint(equalTo: templateListContentView.topAnchor)
    let templatePreviewCollectionViewBottomAnchorConstraint = templatePreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: templateListContentView.bottomAnchor)
    let templateFileListViewTopAnchorConstraint = templateFileListView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor)
    let templateFileListViewLeadingAnchorConstraint = templateFileListView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let templateFileListViewTrailingAnchorConstraint = templateFileListView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor)

    cancelButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view5ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    doneButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      contentAreaViewTopAnchorConstraint,
      contentAreaViewLeadingAnchorConstraint,
      contentAreaViewTrailingAnchorConstraint,
      divider5ViewTopAnchorConstraint,
      divider5ViewLeadingAnchorConstraint,
      divider5ViewTrailingAnchorConstraint,
      view4ViewBottomAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view4ViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      contentAreaViewHeightAnchorConstraint,
      templateListContainerViewLeadingAnchorConstraint,
      templateListContainerViewTopAnchorConstraint,
      templateListContainerViewBottomAnchorConstraint,
      vDividerViewLeadingAnchorConstraint,
      vDividerViewTopAnchorConstraint,
      vDividerViewBottomAnchorConstraint,
      fileListContainerViewTrailingAnchorConstraint,
      fileListContainerViewLeadingAnchorConstraint,
      fileListContainerViewTopAnchorConstraint,
      fileListContainerViewBottomAnchorConstraint,
      divider5ViewHeightAnchorConstraint,
      cancelButtonViewHeightAnchorParentConstraint,
      view5ViewHeightAnchorParentConstraint,
      doneButtonViewHeightAnchorParentConstraint,
      cancelButtonViewLeadingAnchorConstraint,
      cancelButtonViewTopAnchorConstraint,
      cancelButtonViewBottomAnchorConstraint,
      view5ViewLeadingAnchorConstraint,
      view5ViewTopAnchorConstraint,
      view5ViewBottomAnchorConstraint,
      doneButtonViewTrailingAnchorConstraint,
      doneButtonViewLeadingAnchorConstraint,
      doneButtonViewTopAnchorConstraint,
      doneButtonViewBottomAnchorConstraint,
      templateListTitleViewTopAnchorConstraint,
      templateListTitleViewLeadingAnchorConstraint,
      templateListTitleViewTrailingAnchorConstraint,
      templateListContentViewBottomAnchorConstraint,
      templateListContentViewTopAnchorConstraint,
      templateListContentViewLeadingAnchorConstraint,
      templateListContentViewTrailingAnchorConstraint,
      vDividerViewWidthAnchorConstraint,
      fileListContainerViewWidthAnchorConstraint,
      templateListTitle1ViewTopAnchorConstraint,
      templateListTitle1ViewLeadingAnchorConstraint,
      templateListTitle1ViewTrailingAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      templatePreviewCollectionViewLeadingAnchorConstraint,
      templatePreviewCollectionViewTrailingAnchorConstraint,
      templatePreviewCollectionViewTopAnchorConstraint,
      templatePreviewCollectionViewBottomAnchorConstraint,
      templateFileListViewTopAnchorConstraint,
      templateFileListViewLeadingAnchorConstraint,
      templateFileListViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    doneButtonView.onClick = handleOnClickDone
    cancelButtonView.onClick = handleOnClickCancel
    templatePreviewCollectionView.templateTitles = templateTitles
    templatePreviewCollectionView.templateDescriptions = templateDescriptions
    templatePreviewCollectionView.templateImages = templateImages
    templateFileListView.fileNames = selectedTemplateFiles
    templatePreviewCollectionView.selectedTemplateIndex = selectedTemplateIndex
    templatePreviewCollectionView.onSelectTemplateIndex = handleOnChangeSelectedTemplateIndex
    templatePreviewCollectionView.onDoubleClickTemplateIndex = handleOnDoubleClickTemplateIndex
  }

  private func handleOnClickDone() {
    onClickDone?()
  }

  private func handleOnClickCancel() {
    onClickCancel?()
  }

  private func handleOnChangeSelectedTemplateIndex(_ arg0: Int) {
    onChangeSelectedTemplateIndex?(arg0)
  }

  private func handleOnDoubleClickTemplateIndex(_ arg0: Int) {
    onDoubleClickTemplateIndex?(arg0)
  }
}

// MARK: - Parameters

extension TemplateBrowser {
  public struct Parameters: Equatable {
    public var templateTitles: [String]
    public var templateDescriptions: [String]
    public var templateImages: [NSImage]
    public var selectedTemplateIndex: Int
    public var selectedTemplateFiles: [String]
    public var onClickDone: (() -> Void)?
    public var onClickCancel: (() -> Void)?
    public var onChangeSelectedTemplateIndex: ((Int) -> Void)?
    public var onDoubleClickTemplateIndex: ((Int) -> Void)?

    public init(
      templateTitles: [String],
      templateDescriptions: [String],
      templateImages: [NSImage],
      selectedTemplateIndex: Int,
      selectedTemplateFiles: [String],
      onClickDone: (() -> Void)? = nil,
      onClickCancel: (() -> Void)? = nil,
      onChangeSelectedTemplateIndex: ((Int) -> Void)? = nil,
      onDoubleClickTemplateIndex: ((Int) -> Void)? = nil)
    {
      self.templateTitles = templateTitles
      self.templateDescriptions = templateDescriptions
      self.templateImages = templateImages
      self.selectedTemplateIndex = selectedTemplateIndex
      self.selectedTemplateFiles = selectedTemplateFiles
      self.onClickDone = onClickDone
      self.onClickCancel = onClickCancel
      self.onChangeSelectedTemplateIndex = onChangeSelectedTemplateIndex
      self.onDoubleClickTemplateIndex = onDoubleClickTemplateIndex
    }

    public init() {
      self
        .init(
          templateTitles: [],
          templateDescriptions: [],
          templateImages: [],
          selectedTemplateIndex: 0,
          selectedTemplateFiles: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.templateTitles == rhs.templateTitles &&
        lhs.templateDescriptions == rhs.templateDescriptions &&
          lhs.templateImages == rhs.templateImages &&
            lhs.selectedTemplateIndex == rhs.selectedTemplateIndex &&
              lhs.selectedTemplateFiles == rhs.selectedTemplateFiles
    }
  }
}

// MARK: - Model

extension TemplateBrowser {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TemplateBrowser"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      templateTitles: [String],
      templateDescriptions: [String],
      templateImages: [NSImage],
      selectedTemplateIndex: Int,
      selectedTemplateFiles: [String],
      onClickDone: (() -> Void)? = nil,
      onClickCancel: (() -> Void)? = nil,
      onChangeSelectedTemplateIndex: ((Int) -> Void)? = nil,
      onDoubleClickTemplateIndex: ((Int) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            templateTitles: templateTitles,
            templateDescriptions: templateDescriptions,
            templateImages: templateImages,
            selectedTemplateIndex: selectedTemplateIndex,
            selectedTemplateFiles: selectedTemplateFiles,
            onClickDone: onClickDone,
            onClickCancel: onClickCancel,
            onChangeSelectedTemplateIndex: onChangeSelectedTemplateIndex,
            onDoubleClickTemplateIndex: onDoubleClickTemplateIndex))
    }

    public init() {
      self
        .init(
          templateTitles: [],
          templateDescriptions: [],
          templateImages: [],
          selectedTemplateIndex: 0,
          selectedTemplateFiles: [])
    }
  }
}
