type logicValue =
  | Identifier(Types.lonaType, list(string))
  | Literal(Types.lonaValue);

type logicNode =
  | If(logicValue, Types.cmp, logicValue, logicNode)
  | IfExists(logicValue, logicNode)
  | Assign(logicValue, logicValue)
  | Add(logicValue, logicValue, logicValue)
  | Let(logicValue)
  | Block(list(logicNode))
  | None;

module IdentifierSet = {
  include
    Set.Make(
      {
        type t = (Types.lonaType, list(string));
        let compare = (a: t, b: t) : int => {
          let (_, a) = a;
          let (_, b) = b;
          compare(Render.String.join("", a), Render.String.join("", b))
        };
      }
    );
};

module LogicTree =
  Tree.Make(
    {
      type t = logicNode;
      let children = (node) =>
        switch node {
        | If(_, _, _, value) => [value]
        | Add(_, _, _) => []
        | Assign(_, _) => []
        | IfExists(_, value) => [value]
        | Block(body) => body
        | Let(_) => []
        | None => []
        };
      let restore = (node, contents) => {
        let at = (index) => List.nth(contents, index);
        switch node {
        | If(a, b, c, _) => If(a, b, c, at(0))
        | Add(_, _, _) => node
        | Assign(_, _) => node
        | IfExists(a, _) => IfExists(a, at(0))
        | Block(_) => Block(contents)
        | Let(_) => node
        | None => node
        }
      };
    }
  );

let getValueType = (value) =>
  switch value {
  | Identifier(ltype, _) => ltype
  | Literal(lvalue) => lvalue.ltype
  };

/* TODO: This only looks at assignments */
let undeclaredIdentifiers = (node) => {
  let inner = (node, identifiers) =>
    switch node {
    | Assign(_, Identifier(type_, path)) => IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node)
};

let assignedIdentifiers = (node) => {
  let inner = (node, identifiers) =>
    switch node {
    | Assign(_, Identifier(type_, path)) => IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node)
};

let conditionallyAssignedIdentifiers = (rootNode) => {
  let identifiers = undeclaredIdentifiers(rootNode);
  let paths = identifiers |> IdentifierSet.elements;
  let rec isAlwaysAssigned = (target, node) =>
    switch node {
    | Assign(_, Identifier(_, path)) => path == target
    | If(_, _, Identifier(_, path), body) when path == target => isAlwaysAssigned(target, body)
    | Block(nodes) => nodes |> List.exists(isAlwaysAssigned(target))
    | _ => false
    };
  let accumulate = (set, (ltype, path)) =>
    isAlwaysAssigned(path, rootNode) ? set : IdentifierSet.add((ltype, path), set);
  paths |> List.fold_left(accumulate, IdentifierSet.empty)
};

/* let testNode = Assign(Identifier(Reference("OK"), ["a"]), Identifier(Reference("OK"), ["b"])); */
let addVariableDeclarations = (node) => {
  let identifiers = undeclaredIdentifiers(node);
  identifiers
  |> IdentifierSet.elements
  |> List.map(((type_, path)) => Let(Identifier(type_, path)))
  |> List.fold_left(
       (acc, declaration) =>
         LogicTree.insert_child((item) => item == acc ? Some(declaration) : None, acc),
       node
     )
};

let prepend = (newNode, node) => Block([newNode, node]);

let append = (newNode, node) => Block([node, newNode]);

/* let declareVariable = (lonaType, name, node) => {
     let lonaValue = Identifier(lonaType, name);
     let letNode = Let(lonaValue);
     prepend(letNode, node)
   }; */
let setIdentiferName = (name, value) =>
  switch value {
  | Identifier(lonaType, _) => Identifier(lonaType, name)
  | _ => value
  };

let replaceIdentifierName = (oldName, newName, value) =>
  switch value {
  | Identifier(lonaType, name) when name == oldName => Identifier(lonaType, newName)
  | _ => value
  };

let rec replaceIdentifiersNamed = (oldName, newName, node) => {
  let replace = replaceIdentifierName(oldName, newName);
  let replaceChild = replaceIdentifiersNamed(oldName, newName);
  switch node {
  | If(a, cmp, b, body) => If(replace(a), cmp, replace(b), body |> replaceChild)
  | IfExists(a, body) => IfExists(replace(a), body |> replaceChild)
  | Assign(a, b) => Assign(replace(a), replace(b))
  | Add(a, b, c) => Add(replace(a), replace(b), replace(c))
  | Let(a) => Let(replace(a))
  | Block(body) => Block(body |> List.map(replaceChild))
  | _ => node
  }
};

let addIntermediateVariable = (identifier, newName, defaultValue, node) => {
  let ltype = getValueType(identifier);
  let oldName =
    switch identifier {
    | Identifier(_, oldName) => oldName
    | Literal(_) => raise(Not_found)
    };
  let newVariable = Identifier(ltype, newName);
  let node =
    Block([
      Let(newVariable),
      Assign(defaultValue, newVariable),
      replaceIdentifiersNamed(oldName, newName, node),
      Assign(newVariable, identifier)
    ]);
  node
};