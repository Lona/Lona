import Foundation
import Cocoa

extension CSTextStyle: Identify {
    var ID: String { return self.id }
}

extension CSTextStyle: Searchable {    
}

class TextStylePickerButton: NSButton, CSControl {
    
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
        let picker = initPickerView()
        picker.popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }
    
    func handleClick() {
        showPopover()
    }
    
    private func smallSizeAttributeText(with csFont: AttributedFont) -> NSAttributedString {
        csFont.fontSize = 14
        return csFont.apply(to: value)
    }
}

extension TextStylePickerButton {
    
    private struct Constant {
        static let maxWidth: CGFloat = 1000
        static let minHeightRow: CGFloat = 32.0
        static let maxHeightRow: CGFloat = 200.0
    }
    
    fileprivate func initPickerView() -> PickerView<CSTextStyle> {
        let options: [PickerView<CSTextStyle>.Option] = [
            .data(CSTypography.styles),
            .didSelectItem({[weak self] (picker, item) in
                guard let strongSelf = self else { return }
                picker?.popover.close()
                strongSelf.value = item.id
                strongSelf.onChange(strongSelf.value)
                strongSelf.onChangeData(strongSelf.data)
            }),
            .placeholderText("Search text style ..."),
            .selected(data.string!),
            .sizeForRow({[unowned self] (textStyle) -> NSSize in
                let text = textStyle.font.apply(to: textStyle.name)
                return self.fitTextSize(text)
            }),
            .viewForItem({ (tableView, item, selected) -> PickerRowViewType in
                return TextStyleRowView(textStyle: item, selected: selected)
            })
            
        ]
        return PickerView<CSTextStyle>.init(options: options)
    }
    
    private func fitSize(with attributeString: NSAttributedString) -> NSSize {
        let fixedSize = NSSize(width: Constant.maxWidth, height: Constant.maxHeightRow)
        return attributeString.boundingRect(with: fixedSize,
                                            options: .usesFontLeading).size
    }
    
    private func fitTextSize(_ attributeText: NSAttributedString) -> NSSize {
        let size = fitSize(with: attributeText)
        var height = size.height
        height = min(height, Constant.maxHeightRow)
        height = max(height, Constant.minHeightRow)
        return NSSize(width: size.width, height: height)
    }
}
