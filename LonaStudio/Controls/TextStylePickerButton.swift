import Foundation
import Cocoa

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
        let picker = TextStylePickerView(selectedID: data.string!)
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = picker.embeddedViewController()
        popover.contentSize = picker.bounds.size
        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        picker.onClickFont = { [weak self ] textStyle in
            guard let strongSelf = self else { return }
            popover.close()
            strongSelf.value = textStyle.id
            strongSelf.onChange(strongSelf.value)
            strongSelf.onChangeData(strongSelf.data)
        }
    }
    
    func handleClick() {
        showPopover()
    }
    
    private func smallSizeAttributeText(with csFont: AttributedFont) -> NSAttributedString {
        csFont.fontSize = 14
        return csFont.apply(to: value)
    }
}
