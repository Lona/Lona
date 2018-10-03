type logicValue =
  | Identifier(Types.lonaType, list(string))
  | Literal(Types.lonaValue);

type logicNode =
  | If(logicValue, Types.cmp, logicValue, logicNode)
  | IfExists(logicValue, logicNode)
  | Assign(logicValue, logicValue)
  | Add(logicValue, logicValue, logicValue)
  | Let(logicValue)
  | LetEqual(logicValue, logicValue)
  | Block(list(logicNode))
  | None;

let logicValueToString = (value: logicValue): string =>
  switch (value) {
  | Identifier(ltype, ids) =>
    "Identifier("
    ++ Js.String.make(ids)
    ++ ":"
    ++ Js.String.make(ltype)
    ++ ")"
  | Literal(lvalue) =>
    "Literal("
    ++ Js.String.make(lvalue.data)
    ++ ":"
    ++ Js.String.make(lvalue.ltype)
    ++ ")"
  };

module IdentifierSet = {
  include Set.Make({
    type t = (Types.lonaType, list(string));
    let compare = (a: t, b: t): int => {
      let (_, a) = a;
      let (_, b) = b;
      compare(Render.String.join("", a), Render.String.join("", b));
    };
  });
};

module LogicTree =
  Tree.Make({
    type t = logicNode;
    let children = node =>
      switch (node) {
      | If(_, _, _, value) => [value]
      | Add(_, _, _) => []
      | Assign(_, _) => []
      | IfExists(_, value) => [value]
      | Block(body) => body
      | Let(_) => []
      | LetEqual(_, _) => []
      | None => []
      };
    let restore = (node, contents) => {
      let at = index => List.nth(contents, index);
      switch (node) {
      | If(a, b, c, _) => If(a, b, c, at(0))
      | Add(_, _, _) => node
      | Assign(_, _) => node
      | IfExists(a, _) => IfExists(a, at(0))
      | Block(_) => Block(contents)
      | Let(_) => node
      | LetEqual(_, _) => node
      | None => node
      };
    };
  });

let getValueType = value =>
  switch (value) {
  | Identifier(ltype, _) => ltype
  | Literal(lvalue) => lvalue.ltype
  };

/* TODO: This should cover every kind of logic node */
let accessedIdentifiers = node => {
  let addLogicValue = (value, identifiers) =>
    switch (value) {
    | Identifier(type_, path) =>
      IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  let rec inner = (node, identifiers) =>
    switch (node) {
    | Assign(a, b) =>
      let identifiers = addLogicValue(a, identifiers);
      addLogicValue(b, identifiers);
    | If(a, _, b, node) =>
      let identifiers = addLogicValue(a, identifiers);
      let identifiers = addLogicValue(b, identifiers);
      inner(node, identifiers);
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node);
};

let assignedIdentifiers = node => {
  let inner = (node, identifiers) =>
    switch (node) {
    | Assign(_, Identifier(type_, path)) =>
      IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node);
};

let isLayerParameterAssigned = (logicNode, parameterName, layer: Types.layer) => {
  let isAssigned = ((_, value)) =>
    value == ["layers", layer.name, parameterName];
  assignedIdentifiers(logicNode) |> IdentifierSet.exists(isAssigned);
};

/* Exclusively returns variables that are conditionally assigned and
 * not assigned outside of a conditional.
 */
let conditionallyAssignedIdentifiers = rootNode => {
  let identifiers = assignedIdentifiers(rootNode);
  let paths = identifiers |> IdentifierSet.elements;
  let rec isAlwaysAssigned = (target, node) =>
    switch (node) {
    | Assign(_, Identifier(_, path)) => path == target
    | If(_, _, Identifier(_, path), body) when path == target =>
      isAlwaysAssigned(target, body)
    | Block(nodes) => nodes |> List.exists(isAlwaysAssigned(target))
    | _ => false
    };
  let accumulate = (set, (ltype, path)) =>
    isAlwaysAssigned(path, rootNode) ?
      set : IdentifierSet.add((ltype, path), set);
  paths |> List.fold_left(accumulate, IdentifierSet.empty);
};

let buildVariableDeclarations = node => {
  let identifiers = accessedIdentifiers(node);
  let nodes =
    identifiers
    |> IdentifierSet.elements
    /* Filter identifiers beginning with "parameters", since these are
     * already declared within the React props or component class */
    |> List.filter(((_, path)) =>
         switch (path) {
         | [hd, _] => hd != "parameters"
         | _ => true
         }
       )
    |> List.map(((type_, path)) => Let(Identifier(type_, path)));
  Block(nodes);
};

let prepend = (newNode, node) => Block([newNode, node]);

let append = (newNode, node) => Block([node, newNode]);

let setIdentiferName = (name, value) =>
  switch (value) {
  | Identifier(lonaType, _) => Identifier(lonaType, name)
  | _ => value
  };

let replaceIdentifierName = (oldName, newName, value) =>
  switch (value) {
  | Identifier(lonaType, name) when name == oldName =>
    Identifier(lonaType, newName)
  | _ => value
  };

let rec replaceIdentifiersNamed = (oldName, newName, node) => {
  let replace = replaceIdentifierName(oldName, newName);
  let replaceChild = replaceIdentifiersNamed(oldName, newName);
  switch (node) {
  | If(a, cmp, b, body) =>
    If(replace(a), cmp, replace(b), body |> replaceChild)
  | IfExists(a, body) => IfExists(replace(a), body |> replaceChild)
  | Assign(a, b) => Assign(replace(a), replace(b))
  | Add(a, b, c) => Add(replace(a), replace(b), replace(c))
  | Let(a) => Let(replace(a))
  | LetEqual(a, b) => LetEqual(replace(a), replace(b))
  | Block(body) => Block(body |> List.map(replaceChild))
  | None => node
  };
};

let addIntermediateVariable = (identifier, newName, defaultValue, node) => {
  let ltype = getValueType(identifier);
  let oldName =
    switch (identifier) {
    | Identifier(_, oldName) => oldName
    | Literal(_) => raise(Not_found)
    };
  let newVariable = Identifier(ltype, newName);
  let node =
    Block([
      LetEqual(newVariable, defaultValue),
      replaceIdentifiersNamed(oldName, newName, node),
      Assign(newVariable, identifier),
    ]);
  node;
};

let defaultValueForType = (lonaType: Types.lonaType) =>
  switch (lonaType) {
  | Reference("Boolean") => LonaValue.boolean(false)
  | Reference("Number") => LonaValue.number(0.)
  | Reference("String") => LonaValue.string("")
  | _ =>
    Js.log("No default value for lonaType");
    raise(Not_found);
  };

let defaultValueForLayerParameter = (config: Config.t, layer, parameterName) =>
  switch (parameterName) {
  | ParameterKey.TextStyle =>
    LonaValue.textStyle(config.textStylesFile.contents.defaultStyle.id)
  | ParameterKey.BackgroundColor => LonaValue.color("transparent")
  | _ => LonaValue.defaultValueForParameter(parameterName)
  };

let assignmentForLayerParameter =
    (layer: Types.layer, parameterName, value: Types.lonaValue) => {
  let receiver =
    Identifier(
      value.ltype,
      ["layers", layer.name, parameterName |> ParameterKey.toString],
    );
  let source = Literal(value);
  Assign(source, receiver);
};

let defaultAssignmentForLayerParameter =
    (config: Config.t, layer: Types.layer, parameterName) => {
  let value = defaultValueForLayerParameter(config, layer, parameterName);
  assignmentForLayerParameter(layer, parameterName, value);
};

let enforceSingleAssignment = (getIntermediateName, getDefaultValue, node) => {
  let identifiers = conditionallyAssignedIdentifiers(node);
  let addVariable = (node, (lonaType, name)) => {
    let newName = getIntermediateName(lonaType, name);
    let defaultValue = getDefaultValue(lonaType, name);
    node
    |> addIntermediateVariable(
         Identifier(lonaType, name),
         newName,
         defaultValue,
       );
  };
  List.fold_left(addVariable, node, identifiers |> IdentifierSet.elements);
};