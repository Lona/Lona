import AppKit
import Foundation

// MARK: - TextStylePreviewCollection

public class TextStylePreviewCollection: NSBox {

  // MARK: Lifecycle

  public init(
    onSelectTextStyle: TextStyleHandler,
    onChangeTextStyle: TextStyleHandler,
    onDeleteTextStyle: TextStyleHandler,
    onMoveTextStyle: ItemMoveHandler,
    textStyles: TextStyleList)
  {
    self.onSelectTextStyle = onSelectTextStyle
    self.onChangeTextStyle = onChangeTextStyle
    self.onDeleteTextStyle = onDeleteTextStyle
    self.onMoveTextStyle = onMoveTextStyle
    self.textStyles = textStyles

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self
      .init(
        onSelectTextStyle: nil,
        onChangeTextStyle: nil,
        onDeleteTextStyle: nil,
        onMoveTextStyle: nil,
        textStyles: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectTextStyle: TextStyleHandler { didSet { update() } }
  public var onChangeTextStyle: TextStyleHandler { didSet { update() } }
  public var onDeleteTextStyle: TextStyleHandler { didSet { update() } }
  public var onMoveTextStyle: ItemMoveHandler { didSet { update() } }
  public var textStyles: TextStyleList { didSet { update() } }

  // MARK: Private

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    fillColor = Colors.pink50
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func update() {}
}
