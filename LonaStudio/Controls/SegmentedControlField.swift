import Foundation
import Cocoa

class SegmentedControlField: NSSegmentedControl {

    var value: String {
        get { return label(forSegment: selectedSegment) ?? "" }
        set {
            for index in 0..<segmentCount {
                let segmentLabel = label(forSegment: index)

                if segmentLabel == newValue {
                    setSelected(true, forSegment: index)
                }
            }

            onChange(newValue)
        }
    }

    var onChange: (String) -> Void = {_ in }

    var segmentWidth: CGFloat {
        get { return 0 }
        set {
            for index in 0..<segmentCount {
                setWidth(newValue, forSegment: index)
            }
        }
    }

    func setup(values: [String]) {
        action = #selector(handleChange)
        target = self

        segmentCount = values.count
        for (index, value) in values.enumerated() {
            setLabel(value, forSegment: index)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(values: [])
    }

    init(frame frameRect: NSRect, values: [String] = []) {
        super.init(frame: frameRect)
        setup(values: values)
    }

    @objc func handleChange() {
        Swift.print("handle change", value)
        onChange(value)
    }
}
