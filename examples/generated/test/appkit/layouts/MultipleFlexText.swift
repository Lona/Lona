import AppKit
import Foundation

// MARK: - MultipleFlexText

public class MultipleFlexText: NSBox {

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
  private var textView = LNATextField(labelWithString: "")
  private var view2View = NSBox()
  private var view4View = NSBox()
  private var text1View = LNATextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.body1
  private var text1ViewTextStyle = TextStyles.body1

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
    textView.lineBreakMode = .byWordWrapping
    view4View.boxType = .custom
    view4View.borderType = .noBorder
    view4View.contentViewMargins = .zero
    text1View.lineBreakMode = .byWordWrapping

    addSubview(view1View)
    addSubview(view2View)
    view1View.addSubview(view3View)
    view3View.addSubview(textView)
    view2View.addSubview(view4View)
    view4View.addSubview(text1View)

    view1View.fillColor = Colors.red50
    textView.attributedStringValue = textViewTextStyle.apply(to: "Some long text (currently LS lays out incorrectly)")
    view2View.fillColor = Colors.blue50
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Short")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewView2ViewWidthAnchorSiblingConstraint = view1View
      .widthAnchor
      .constraint(equalTo: view2View.widthAnchor)
    let view1ViewHeightAnchorParentConstraint = view1View.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
    let view2ViewHeightAnchorParentConstraint = view2View.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: topAnchor)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 100)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: view1View.topAnchor)
    let view3ViewBottomAnchorConstraint = view3View.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let view3ViewLeadingAnchorConstraint = view3View.leadingAnchor.constraint(equalTo: view1View.leadingAnchor)
    let view3ViewTrailingAnchorConstraint = view3View.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 100)
    let view4ViewTopAnchorConstraint = view4View.topAnchor.constraint(equalTo: view2View.topAnchor)
    let view4ViewBottomAnchorConstraint = view4View.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let view4ViewLeadingAnchorConstraint = view4View.leadingAnchor.constraint(equalTo: view2View.leadingAnchor)
    let view4ViewTrailingAnchorConstraint = view4View.trailingAnchor.constraint(equalTo: view2View.trailingAnchor)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: view3View.topAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: view3View.leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let text1ViewTopAnchorConstraint = text1View.topAnchor.constraint(equalTo: view4View.topAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: view4View.leadingAnchor)
    let text1ViewTrailingAnchorConstraint = text1View.trailingAnchor.constraint(equalTo: view4View.trailingAnchor)

    view1ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view2ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      view1ViewView2ViewWidthAnchorSiblingConstraint,
      view1ViewHeightAnchorParentConstraint,
      view2ViewHeightAnchorParentConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewBottomAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTrailingAnchorConstraint,
      view2ViewHeightAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewBottomAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view4ViewTrailingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint
    ])
  }

  private func update() {}
}
