import AppKit
import Foundation

// MARK: - TextStylesTest

public class TextStylesTest: NSBox {

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

  private var text1View = LNATextField(labelWithString: "")
  private var text2View = LNATextField(labelWithString: "")
  private var text3View = LNATextField(labelWithString: "")
  private var view3View = NSBox()
  private var text4View = LNATextField(labelWithString: "")
  private var view1View = NSBox()
  private var text5View = LNATextField(labelWithString: "")
  private var view2View = NSBox()
  private var text6View = LNATextField(labelWithString: "")
  private var text7View = LNATextField(labelWithString: "")
  private var text8View = LNATextField(labelWithString: "")
  private var text9View = LNATextField(labelWithString: "")

  private var text1ViewTextStyle = TextStyles.display3
  private var text2ViewTextStyle = TextStyles.display2
  private var text3ViewTextStyle = TextStyles.display1
  private var text4ViewTextStyle = TextStyles.headline
  private var text5ViewTextStyle = TextStyles.subheading2
  private var text6ViewTextStyle = TextStyles.subheading1
  private var text7ViewTextStyle = TextStyles.body2
  private var text8ViewTextStyle = TextStyles.body1
  private var text9ViewTextStyle = TextStyles.caption

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    text1View.lineBreakMode = .byWordWrapping
    text2View.lineBreakMode = .byWordWrapping
    text3View.lineBreakMode = .byWordWrapping
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    text7View.lineBreakMode = .byWordWrapping
    text8View.lineBreakMode = .byWordWrapping
    text9View.lineBreakMode = .byWordWrapping
    text4View.lineBreakMode = .byWordWrapping
    text5View.lineBreakMode = .byWordWrapping
    text6View.lineBreakMode = .byWordWrapping

    addSubview(text1View)
    addSubview(text2View)
    addSubview(text3View)
    addSubview(view3View)
    addSubview(view1View)
    addSubview(view2View)
    addSubview(text7View)
    addSubview(text8View)
    addSubview(text9View)
    view3View.addSubview(text4View)
    view1View.addSubview(text5View)
    view2View.addSubview(text6View)

    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Text goes here")
    text1ViewTextStyle = TextStyles.display3
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: text1View.attributedStringValue)
    text2View.attributedStringValue = text2ViewTextStyle.apply(to: "Text goes here")
    text2ViewTextStyle = TextStyles.display2
    text2View.attributedStringValue = text2ViewTextStyle.apply(to: text2View.attributedStringValue)
    text3View.attributedStringValue = text3ViewTextStyle.apply(to: "Text goes here")
    text3ViewTextStyle = TextStyles.display1
    text3View.attributedStringValue = text3ViewTextStyle.apply(to: text3View.attributedStringValue)
    view3View.fillColor = Colors.green50
    text4View.attributedStringValue = text4ViewTextStyle.apply(to: "Text goes here")
    text4ViewTextStyle = TextStyles.headline
    text4View.attributedStringValue = text4ViewTextStyle.apply(to: text4View.attributedStringValue)
    view1View.fillColor = Colors.green100
    text5View.attributedStringValue = text5ViewTextStyle.apply(to: "Text goes here")
    text5ViewTextStyle = TextStyles.subheading2
    text5View.attributedStringValue = text5ViewTextStyle.apply(to: text5View.attributedStringValue)
    view2View.fillColor = Colors.green200
    text6View.attributedStringValue =
      text6ViewTextStyle.apply(to: "Text goes here and wraps around when it reaches the end of the text field.")
    text6ViewTextStyle = TextStyles.subheading1
    text6View.attributedStringValue = text6ViewTextStyle.apply(to: text6View.attributedStringValue)
    text7View.attributedStringValue = text7ViewTextStyle.apply(to: "Text goes here")
    text7ViewTextStyle = TextStyles.body2
    text7View.attributedStringValue = text7ViewTextStyle.apply(to: text7View.attributedStringValue)
    text8View.attributedStringValue = text8ViewTextStyle.apply(to: "Text goes here")
    text8ViewTextStyle = TextStyles.body1
    text8View.attributedStringValue = text8ViewTextStyle.apply(to: text8View.attributedStringValue)
    text9View.attributedStringValue = text9ViewTextStyle.apply(to: "Text goes here")
    text9ViewTextStyle = TextStyles.caption
    text9View.attributedStringValue = text9ViewTextStyle.apply(to: text9View.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    text2View.translatesAutoresizingMaskIntoConstraints = false
    text3View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    text7View.translatesAutoresizingMaskIntoConstraints = false
    text8View.translatesAutoresizingMaskIntoConstraints = false
    text9View.translatesAutoresizingMaskIntoConstraints = false
    text4View.translatesAutoresizingMaskIntoConstraints = false
    text5View.translatesAutoresizingMaskIntoConstraints = false
    text6View.translatesAutoresizingMaskIntoConstraints = false

    let text1ViewTopAnchorConstraint = text1View.topAnchor.constraint(equalTo: topAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text1ViewTrailingAnchorConstraint = text1View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text2ViewTopAnchorConstraint = text2View.topAnchor.constraint(equalTo: text1View.bottomAnchor)
    let text2ViewLeadingAnchorConstraint = text2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text2ViewTrailingAnchorConstraint = text2View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text3ViewTopAnchorConstraint = text3View.topAnchor.constraint(equalTo: text2View.bottomAnchor)
    let text3ViewLeadingAnchorConstraint = text3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text3ViewTrailingAnchorConstraint = text3View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: text3View.bottomAnchor)
    let view3ViewLeadingAnchorConstraint = view3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view3ViewTrailingAnchorConstraint = view3View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: view3View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: view1View.bottomAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let text7ViewTopAnchorConstraint = text7View.topAnchor.constraint(equalTo: view2View.bottomAnchor)
    let text7ViewLeadingAnchorConstraint = text7View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text7ViewTrailingAnchorConstraint = text7View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text8ViewTopAnchorConstraint = text8View.topAnchor.constraint(equalTo: text7View.bottomAnchor)
    let text8ViewLeadingAnchorConstraint = text8View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text8ViewTrailingAnchorConstraint = text8View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text9ViewBottomAnchorConstraint = text9View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let text9ViewTopAnchorConstraint = text9View.topAnchor.constraint(equalTo: text8View.bottomAnchor)
    let text9ViewLeadingAnchorConstraint = text9View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text9ViewTrailingAnchorConstraint = text9View.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let text4ViewTopAnchorConstraint = text4View.topAnchor.constraint(equalTo: view3View.topAnchor)
    let text4ViewBottomAnchorConstraint = text4View.bottomAnchor.constraint(equalTo: view3View.bottomAnchor)
    let text4ViewLeadingAnchorConstraint = text4View.leadingAnchor.constraint(equalTo: view3View.leadingAnchor)
    let text4ViewTrailingAnchorConstraint = text4View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: view3View.trailingAnchor)
    let text5ViewTopAnchorConstraint = text5View.topAnchor.constraint(equalTo: view1View.topAnchor)
    let text5ViewBottomAnchorConstraint = text5View.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let text5ViewLeadingAnchorConstraint = text5View.leadingAnchor.constraint(equalTo: view1View.leadingAnchor)
    let text5ViewTrailingAnchorConstraint = text5View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: view1View.trailingAnchor)
    let text6ViewTopAnchorConstraint = text6View.topAnchor.constraint(equalTo: view2View.topAnchor)
    let text6ViewBottomAnchorConstraint = text6View.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let text6ViewLeadingAnchorConstraint = text6View.leadingAnchor.constraint(equalTo: view2View.leadingAnchor)
    let text6ViewTrailingAnchorConstraint = text6View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: view2View.trailingAnchor)

    NSLayoutConstraint.activate([
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      text2ViewTopAnchorConstraint,
      text2ViewLeadingAnchorConstraint,
      text2ViewTrailingAnchorConstraint,
      text3ViewTopAnchorConstraint,
      text3ViewLeadingAnchorConstraint,
      text3ViewTrailingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTrailingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      text7ViewTopAnchorConstraint,
      text7ViewLeadingAnchorConstraint,
      text7ViewTrailingAnchorConstraint,
      text8ViewTopAnchorConstraint,
      text8ViewLeadingAnchorConstraint,
      text8ViewTrailingAnchorConstraint,
      text9ViewBottomAnchorConstraint,
      text9ViewTopAnchorConstraint,
      text9ViewLeadingAnchorConstraint,
      text9ViewTrailingAnchorConstraint,
      text4ViewTopAnchorConstraint,
      text4ViewBottomAnchorConstraint,
      text4ViewLeadingAnchorConstraint,
      text4ViewTrailingAnchorConstraint,
      text5ViewTopAnchorConstraint,
      text5ViewBottomAnchorConstraint,
      text5ViewLeadingAnchorConstraint,
      text5ViewTrailingAnchorConstraint,
      text6ViewTopAnchorConstraint,
      text6ViewBottomAnchorConstraint,
      text6ViewLeadingAnchorConstraint,
      text6ViewTrailingAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension TextStylesTest {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension TextStylesTest {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TextStylesTest"
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
