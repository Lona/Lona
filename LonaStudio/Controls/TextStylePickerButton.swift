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
        attributedTitle = CSTypography.getFontBy(id: value).font.apply(to: value)
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
        let textStylePickerView = TextStylePickerView()
        
        let vc = NSViewController()
        vc.view = textStylePickerView
        
        let popover = NSPopover()
        popover.contentSize = textStylePickerView.frame.size
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = vc
        
        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        
        textStylePickerView.onClickFont = { textStyle in
            popover.close()
            self.value = textStyle.id
            self.onChange(self.value)
            self.onChangeData(self.data)
        }
    }
    
    func handleClick() {
        showPopover()
    }
}
