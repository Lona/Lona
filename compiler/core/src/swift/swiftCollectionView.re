let template =
    (
      cellRegistration: string,
      cellConfiguration: string,
      cellSelection: string,
      layoutFittingCompressedSizeConstantName: string,
      collectionViewFlowLayoutAutomaticSize: string,
    ) => {j|
import UIKit

// MARK: - LonaCollectionViewCell

public class LonaCollectionViewCell<T: UIView>: UICollectionViewCell {

  // MARK: Lifecycle

  override public init(frame: CGRect) {
    super.init(frame: frame)

    setUpViews()
    setUpConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var view: T = T()

  public var scrollDirection = UICollectionView.ScrollDirection.vertical

  override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutIfNeeded()

    let preferredLayoutAttributes =
      super.preferredLayoutAttributesFitting(layoutAttributes)
    preferredLayoutAttributes.bounds = layoutAttributes.bounds

    switch scrollDirection {
    case .vertical:
      preferredLayoutAttributes.bounds.size.height = systemLayoutSizeFitting(
        $layoutFittingCompressedSizeConstantName,
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .defaultLow).height
    case .horizontal:
      preferredLayoutAttributes.bounds.size.width = systemLayoutSizeFitting(
        $layoutFittingCompressedSizeConstantName,
        withHorizontalFittingPriority: .defaultLow,
        verticalFittingPriority: .required).width
    }

    return preferredLayoutAttributes
  }

  // MARK: Private

  private func setUpViews() {
    contentView.addSubview(view)
  }

  private func setUpConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

    let width = contentView.widthAnchor.constraint(equalTo: widthAnchor)
    width.priority = .required - 1
    width.isActive = true

    let height = contentView.heightAnchor.constraint(equalTo: heightAnchor)
    height.priority = .required - 1
    height.isActive = true

    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
  }

}

// MARK: - LonaCollectionViewListLayout

public class LonaCollectionViewListLayout: UICollectionViewFlowLayout {
  override public init() {
    super.init()

    self.minimumInteritemSpacing = 0
    self.minimumLineSpacing = 0
    self.sectionInset = .zero
    self.estimatedItemSize = $collectionViewFlowLayoutAutomaticSize
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath),
      let collectionView = collectionView else { return nil }

    switch scrollDirection {
    case .vertical:
      layoutAttributes.bounds.size.width =
        collectionView.safeAreaLayoutGuide.layoutFrame.width -
        sectionInset.left - sectionInset.right -
        collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
    case .horizontal:
      layoutAttributes.bounds.size.height =
        collectionView.safeAreaLayoutGuide.layoutFrame.height -
        sectionInset.top - sectionInset.bottom -
        collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom
    }

    return layoutAttributes
  }

  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

    let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
      return layoutAttribute.representedElementCategory == .cell
        ? layoutAttributesForItem(at: layoutAttribute.indexPath)
        : layoutAttribute
    }

    return computedAttributes
  }
}

// MARK: - LonaCollectionView

public class LonaCollectionView: UICollectionView,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout {

  // MARK: Lifecycle

  private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    parameters = Parameters()

    super.init(frame: frame, collectionViewLayout: LonaCollectionViewListLayout())

    contentInsetAdjustmentBehavior = .automatic
    backgroundColor = .clear

    delegate = self
    dataSource = self

    register(LonaNestedCollectionViewCell.self, forCellWithReuseIdentifier: LonaNestedCollectionViewCell.identifier)
    $cellRegistration
  }

  public convenience init(
    _ parameters: Parameters = Parameters(),
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {
    self.init(frame: .zero, collectionViewLayout: layout)

    let oldParameters = self.parameters
    self.parameters = parameters

    parametersDidChange(oldValue: oldParameters)
  }

  public convenience init(
    items: [LonaViewModel] = [],
    scrollDirection: UICollectionView.ScrollDirection = .vertical,
    padding: UIEdgeInsets = .zero,
    itemSpacing: CGFloat = 0,
    fixedSize: CGFloat? = nil,
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {
    self.init(
      Parameters(
        items: items,
        scrollDirection: scrollDirection,
        padding: padding,
        itemSpacing: itemSpacing,
        fixedSize: fixedSize),
      collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var parameters: Parameters {
    didSet {
      parametersDidChange(oldValue: oldValue)
    }
  }

  public var items: [LonaViewModel] {
    get { return parameters.items }
    set { parameters.items = newValue }
  }

  public var scrollDirection: UICollectionView.ScrollDirection {
    get { return parameters.scrollDirection }
    set { parameters.scrollDirection = newValue }
  }

  // MARK: Data Source

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let item = items[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.type, for: indexPath)
    let scrollDirection = self.scrollDirection

    switch (item.type) {
    case LonaNestedCollectionViewCell.identifier:
      if let cell = cell as? LonaNestedCollectionViewCell, let item = item as? LonaCollectionView.Model {
        cell.parameters = item.parameters
        cell.scrollDirection = scrollDirection
        cell.view.onSelectItem = onSelectItem
      }$cellConfiguration
    default:
      break
    }

    return cell
  }

  // MARK: Delegate

  public var onSelectItem: ((Int) -> Void)?

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let cell = cellForItem(at: indexPath)

    switch (item.type) {$cellSelection
    default:
      break
    }

    onSelectItem?(indexPath.item)
  }

  // MARK: Layout

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch scrollDirection {
    case .horizontal:
      return CGSize(width: 50, height: collectionView.safeAreaLayoutGuide.layoutFrame.height)
    case .vertical:
      return CGSize(width: collectionView.safeAreaLayoutGuide.layoutFrame.width, height: 50)
    }
  }

  // MARK: Scrolling

  override public func touchesShouldCancel(in view: UIView) -> Bool {
    if view is LonaControl {
      return true
    }

    return super.touchesShouldCancel(in: view)
  }

  // MARK: Private

  private func updateAlwaysBounce(for scrollDirection: ScrollDirection) {
    alwaysBounceVertical = scrollDirection == .vertical
    alwaysBounceHorizontal = scrollDirection == .horizontal
  }

  private func parametersDidChange(oldValue: Parameters) {
    updateAlwaysBounce(for: parameters.scrollDirection)
    contentInset = parameters.padding

    switch parameters.scrollDirection {
    case .horizontal:
      showsHorizontalScrollIndicator = false
    case .vertical:
      showsHorizontalScrollIndicator = true
    }
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = parameters.itemSpacing
      layout.scrollDirection = parameters.scrollDirection
      layout.invalidateLayout()
    }

    reloadData()
    layoutIfNeeded()

    contentOffset = CGPoint(
      x: contentOffset.x - parameters.padding.left + oldValue.padding.left,
      y: contentOffset.y - parameters.padding.top + oldValue.padding.top)
  }
}


// MARK: - Parameters

extension LonaCollectionView {
  public struct Parameters {
    public var items: [LonaViewModel]
    public var scrollDirection: UICollectionView.ScrollDirection
    public var padding: UIEdgeInsets
    public var itemSpacing: CGFloat
    public var fixedSize: CGFloat?

    public init(
      items: [LonaViewModel],
      scrollDirection: UICollectionView.ScrollDirection,
      padding: UIEdgeInsets,
      itemSpacing: CGFloat,
      fixedSize: CGFloat? = nil)
    {
      self.items = items
      self.scrollDirection = scrollDirection
      self.padding = padding
      self.itemSpacing = itemSpacing
      self.fixedSize = fixedSize
    }

    public init() {
      self.init(items: [], scrollDirection: .vertical, padding: .zero, itemSpacing: 0)
    }
  }
}

// MARK: - Model

extension LonaCollectionView {
  public struct Model: LonaViewModel {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "LonaCollectionView"
    }

    public init(id: String?, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      items: [LonaViewModel],
      scrollDirection: UICollectionView.ScrollDirection,
      padding: UIEdgeInsets = .zero,
      itemSpacing: CGFloat = 0,
      fixedSize: CGFloat? = nil)
    {
      self.init(
        Parameters(
          items: items,
          scrollDirection: scrollDirection,
          padding: padding,
          itemSpacing: itemSpacing,
          fixedSize: fixedSize))
    }

    public init() {
      self.init(items: [], scrollDirection: .vertical)
    }
  }
}

// MARK: - Cell Classes

public class LonaNestedCollectionViewCell: LonaCollectionViewCell<LonaCollectionView> {
  public var parameters: LonaCollectionView.Parameters {
    get { return view.parameters }
    set { view.parameters = newValue }
  }
  public static var identifier: String {
    return "LonaCollectionView"
  }
  override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    let preferredLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

    if let fixedSize = parameters.fixedSize {
      switch scrollDirection {
      case .vertical:
        preferredLayoutAttributes.bounds.size.height = fixedSize
      case .horizontal:
        preferredLayoutAttributes.bounds.size.width = fixedSize
      }
    }

    return preferredLayoutAttributes
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    if (contentView.bounds != view.bounds) {
      view.collectionViewLayout.invalidateLayout()
    }
  }
}|j};

module Ast = {
  open SwiftAst;

  let cellIdentifierStaticVariable = name =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("identifier"),
          "annotation": Some(TypeName("String")),
        }),
      "init": None,
      "block":
        Some(
          GetterBlock([
            ReturnStatement(Some(LiteralExpression(String(name)))),
          ]),
        ),
    });

  let cellParametersVariable = (className: string): node =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("parameters"),
          "annotation": Some(TypeName(className ++ ".Parameters")),
        }),
      "init": None,
      "block":
        Some(
          GetterSetterBlock({
            "get": [
              ReturnStatement(
                Some(
                  SwiftAst.Builders.memberExpression(["view", "parameters"]),
                ),
              ),
            ],
            "set": [
              BinaryExpression({
                "left":
                  SwiftAst.Builders.memberExpression(["view", "parameters"]),
                "operator": "=",
                "right": SwiftIdentifier("newValue"),
              }),
            ],
          }),
        ),
    });

  let cellIsHighlighted = (): node =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), OverrideModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("isHighlighted"),
          "annotation": Some(TypeName("Bool")),
        }),
      "init": None,
      "block":
        Some(
          WillSetDidSetBlock({
            "willSet": None,
            "didSet":
              Some([
                BinaryExpression({
                  "left":
                    SwiftAst.Builders.memberExpression([
                      "view",
                      "isControlPressed",
                    ]),
                  "operator": "=",
                  "right": SwiftIdentifier("isHighlighted"),
                }),
              ]),
          }),
        ),
    });

  let cellClass = (isInteractive: bool, componentName: string) =>
    ClassDeclaration({
      "name": componentName ++ "Cell",
      "inherits": [
        TypeName("LonaCollectionViewCell<" ++ componentName ++ ">"),
      ],
      "modifier": Some(PublicModifier),
      "isFinal": false,
      "body":
        [
          [cellParametersVariable(componentName)],
          isInteractive ? [cellIsHighlighted()] : [],
          [cellIdentifierStaticVariable(componentName)],
        ]
        |> List.concat,
    });

  let registerCell = (componentName: string): node => {
    let cellName = componentName ++ "Cell";

    Builders.functionCall(
      ["register"],
      [
        (None, [cellName, "self"]),
        (Some("forCellWithReuseIdentifier"), [cellName, "identifier"]),
      ],
    );
  };

  let configureCell =
      (
        isInteractive: bool,
        containsNestedInteractives: bool,
        componentName: string,
      )
      : node => {
    let cellName = componentName ++ "Cell";

    CaseLabel({
      "patterns": [
        ExpressionPattern({
          "value": Builders.memberExpression([cellName, "identifier"]),
        }),
      ],
      "statements": [
        IfStatement({
          "condition":
            ConditionList([
              OptionalBindingCondition({
                "const": true,
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("cell"),
                    "annotation": None,
                  }),
                "init":
                  BinaryExpression({
                    "left": SwiftIdentifier("cell"),
                    "operator": "as?",
                    "right": SwiftIdentifier(cellName),
                  }),
              }),
              OptionalBindingCondition({
                "const": true,
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("item"),
                    "annotation": None,
                  }),
                "init":
                  BinaryExpression({
                    "left": SwiftIdentifier("item"),
                    "operator": "as?",
                    "right":
                      Builders.memberExpression([componentName, "Model"]),
                  }),
              }),
            ]),
          "block":
            [
              BinaryExpression({
                "left": Builders.memberExpression(["cell", "parameters"]),
                "operator": "=",
                "right": Builders.memberExpression(["item", "parameters"]),
              }),
              BinaryExpression({
                "left":
                  Builders.memberExpression(["cell", "scrollDirection"]),
                "operator": "=",
                "right": SwiftIdentifier("scrollDirection"),
              }),
            ]
            @ (
              isInteractive ?
                [
                  BinaryExpression({
                    "left":
                      Builders.memberExpression([
                        "cell",
                        "view",
                        containsNestedInteractives ?
                          "isRootControlTrackingEnabled" : "isEnabled",
                      ]),
                    "operator": "=",
                    "right": LiteralExpression(Boolean(false)),
                  }),
                ] :
                []
            ),
        }),
      ],
    });
  };

  let cellSelection = (componentName: string): node => {
    let cellName = componentName ++ "Cell";

    CaseLabel({
      "patterns": [
        ExpressionPattern({
          "value": Builders.memberExpression([cellName, "identifier"]),
        }),
      ],
      "statements": [
        IfStatement({
          "condition":
            ConditionList([
              OptionalBindingCondition({
                "const": true,
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("cell"),
                    "annotation": None,
                  }),
                "init":
                  BinaryExpression({
                    "left": SwiftIdentifier("cell"),
                    "operator": "as?",
                    "right": SwiftIdentifier(cellName),
                  }),
              }),
            ]),
          "block": [
            Builders.functionCall(
              ["cell", "view", "sendActions"],
              [(Some("for"), [".touchUpInside"])],
            ),
          ],
        }),
      ],
    });
  };

  let print = (nodes: list(node)): string =>
    TopLevelDeclaration({"statements": nodes}) |> SwiftRender.toString;
};

let isInteractive = (config: Config.t, componentName: string): bool => {
  let component = Config.Find.component(config, componentName);
  let rootLayer = Decode.Component.rootLayer(config, component);
  let logic = Decode.Component.logic(component);
  Layer.isInteractive(logic, rootLayer);
};

let interactiveLayers =
    (config: Config.t, componentName: string): list(Types.layer) => {
  let component = Config.Find.component(config, componentName);
  let rootLayer = Decode.Component.rootLayer(config, component);
  let logic = Decode.Component.logic(component);
  rootLayer |> Layer.flatten |> List.filter(Layer.isInteractive(logic));
};

let generate =
    (
      config: Config.t,
      _options: Options.options,
      _swiftOptions: SwiftOptions.options,
      componentNames: list(string),
    ) => {
  let cellRegistration =
    if (List.length(componentNames) > 0) {
      "\n"
      ++ (
        componentNames
        |> List.map(Ast.registerCell)
        |> Ast.print
        |> Js.String.trim
        |> Format.indent(4)
      );
    } else {
      "";
    };

  let cellConfiguration =
    if (List.length(componentNames) > 0) {
      let code =
        componentNames
        |> List.map(name =>
             Ast.configureCell(
               isInteractive(config, name),
               List.length(interactiveLayers(config, name)) > 1,
               name,
             )
           )
        |> Ast.print;
      "\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellSelection =
    if (List.length(componentNames) > 0) {
      let code =
        componentNames
        |> List.filter(isInteractive(config))
        |> List.map(Ast.cellSelection)
        |> Ast.print;
      "\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellClasses =
    componentNames
    |> List.map(name => Ast.cellClass(isInteractive(config, name), name))
    |> SwiftDocument.join(SwiftAst.Empty)
    |> Ast.print
    |> Js.String.trim;

  Format.joinWith(
    "\n\n",
    [
      template(
        cellRegistration,
        cellConfiguration,
        cellSelection,
        SwiftDocument.layoutFittingCompressedSizeConstantName(config),
        SwiftDocument.collectionViewFlowLayoutAutomaticSizeConstantName(
          config,
        ),
      ),
      cellClasses,
    ],
  );
};