import AppKit
import Foundation

// MARK: - ComponentPreview

public class ComponentPreview: NSBox {

    // MARK: Lifecycle

    public init(componentName: String) {
        self.componentName = componentName

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init() {
        self.init(componentName: "")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var componentName: String {
        didSet {
            if oldValue != componentName {
                update()
            }
        }
    }

    // MARK: Private

    private var imageView = NSImageView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        imageView.imageScaling = .scaleProportionallyDown

        addSubview(imageView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
    }

    private func update() {
        guard let component = LonaModule.current.component(named: componentName),
            let canvas = component.computedCanvases().first,
            let caseItem = component.computedCases(for: canvas).first else { return }

        let config = ComponentConfiguration(
            component: component,
            arguments: caseItem.value.objectValue,
            canvas: canvas
        )

        let canvasView = CanvasView(
            canvas: canvas,
            rootLayer: component.rootLayer,
            config: config,
            options: [RenderOption.assetScale(1)]
        )

        guard let data = canvasView.dataRepresentation(scaledBy: 1) else { return }

        imageView.image = NSImage(data: data)
    }
}
