import Foundation
import Cocoa

final class TextStylePickerButton: NSButton, CSControl {

    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var value: String = CSTypography.defaultFont.id {
        didSet {
            setButtonTitle(value: value)
        }
    }

    var onChange: (String) -> Void = {_ in}

    func setup() {
        action = #selector(handleClick)
        target = self

        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded

        setButtonTitle(value: value)
    }

    func setButtonTitle(value: String) {
        // Make sure font size is suitable with textField but keeping another attribute
        let copy = CSTypography.getFontBy(id: value).font.copy() as! AttributedFont
        attributedTitle = smallSizeAttributeText(with: copy)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    func showPopover() {
        let picker = TextStylePickerView(selected: data.stringValue) {[weak self] (item) in
            guard let strongSelf = self else { return }
            strongSelf.value = item.id
            strongSelf.onChange(strongSelf.value)
            strongSelf.onChangeData(strongSelf.data)
        }
        picker.popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }

    @objc func handleClick() {
        showPopover()
    }

    private func smallSizeAttributeText(with csFont: AttributedFont) -> NSAttributedString {
        csFont.fontSize = 14
        return csFont.apply(to: value)
    }
}
