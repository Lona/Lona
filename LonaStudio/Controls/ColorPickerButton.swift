import Foundation
import Cocoa

func createCircularImage(size: Double, color: NSColor) -> NSImage {
    NSGraphicsContext.saveGraphicsState()
    
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    
    let image = NSImage(size: rect.size)
    image.lockFocus()

    let path = NSBezierPath(roundedRect: rect, xRadius: CGFloat(size / 2), yRadius: CGFloat(size / 2))
    path.addClip()
    color.drawSwatch(in: rect)
    
    NSColor(white: 0, alpha: 0.8).set()
    path.stroke()
    
    image.unlockFocus()
    
    NSGraphicsContext.restoreGraphicsState()
    
    return image
}

class ColorPickerButton: NSButton, CSControl {
    
    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }
    
    var onChangeData: (CSData) -> Void = { _ in }
    
    var value: String = "#FFFFFF" {
        didSet {
            setImage()
            title = CSColors.parse(css: value).name
        }
    }

    var onChange: (String) -> Void = {_ in}
    
    func setImage() {
        image = createCircularImage(size: 10, color: CSColors.parse(css: value).color)
    }
    
    func setup() {
        action = #selector(handleClick)
        target = self
        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded

        setImage()
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
        let picker = ColorPickerView(selected: data.stringValue) {[weak self] (color) in
            guard let strongSelf = self else { return }
            strongSelf.title = color.name
            strongSelf.value = color.resolvedValue
            strongSelf.onChange(strongSelf.value)
            strongSelf.onChangeData(strongSelf.data)
        }
        picker.popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }
    
    func handleClick() {
        showPopover()
    }
}
