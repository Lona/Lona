export enum binaryOperator {
  Eq,
  LooseEq,
  Neq,
  LooseNeq,
  Gt,
  Gte,
  Lt,
  Lte,
  Plus,
  Minus,
  And,
  Or,
  Noop,
}

/* Types */
type InterfaceDeclaration = {
  type: 'interfaceDeclaration'
  data: {
    identifier: string
    typeParameters: JSType[]
    objectType: ObjectType
  }
}

type TypeAliasDeclaration = {
  type: 'typeAliasDeclaration'
  data: {
    identifier: string
    typeParameters: JSType[]
    type: JSType
  }
}

export type JSType =
  | { type: 'LiteralType'; data: string }
  | { type: 'UnionType'; data: JSType[] }
  /*   | IntersectionType
            | FunctionType
            | ConstructorType
            | ParenthesizedType
       | PredefinedType(predefinedType)*/
  | { type: 'TypeReference'; data: TypeReference }
  | { type: 'ObjectType'; data: ObjectType }
  /* | ArrayType */
  | { type: 'TupleType'; data: JSType[] }
/* | TypeQuery
   | ThisType */
/* and predefinedType =
   | Any
   | Number
   | Boolean
   | String
   | Symbol
   | Void */

export type ObjectType = { members: TypeMember[] }

export type TypeReference = {
  name: string
  arguments: JSType[]
}

type TypeMember = { type: 'PropertySignature'; data: PropertySignature }

type PropertySignature = {
  name: string
  type?: JSType
}

/* JS */
type ImportDeclaration = {
  source: string
  specifiers: JSNode[]
}
type ImportSpecifier = {
  imported: string
  local?: string
}
type ClassDeclaration = {
  id: string
  superClass?: string
  body: JSNode[]
}
type MethodDefinition = {
  key: string
  value: JSNode
}
type FunctionExpression = {
  id?: string
  params: JSNode[]
  body: JSNode[]
}
type CallExpression = {
  callee: JSNode
  arguments: JSNode[]
}
type MemberExpression = {
  memberName: string
  expression: JSNode
}
type JSXAttribute = {
  name: string
  value: JSNode
}
type JSXElement = {
  tag: string
  attributes: JSNode[]
  content: JSNode[]
}
type AssignmentExpression = {
  left: JSNode
  right: JSNode
}
type BinaryExpression = {
  left: JSNode
  operator: binaryOperator
  right: JSNode
}
type UnaryExpression = {
  prefix: boolean
  operator: string
  argument: JSNode
}
type IfStatement = {
  test: JSNode
  consequent: JSNode[]
  alternate: JSNode[]
}
type ConditionalExpression = {
  test: JSNode
  consequent: JSNode
  alternate: JSNode
}
type Property = {
  key: JSNode
  value?: JSNode
}
type LineEndComment = {
  comment: string
  line: JSNode
}

export type Literal =
  | { type: 'Null'; data: undefined }
  | { type: 'Undefined'; data: undefined }
  | { type: 'Boolean'; data: boolean }
  | { type: 'Number'; data: number }
  | { type: 'String'; data: string }
  | { type: 'Color'; data: string }
  | { type: 'Image'; data: string }
  | { type: 'Array'; data: JSNode[] }
  | { type: 'Object'; data: JSNode[] }

export type JSNode =
  /* Types */
  | { type: 'InterfaceDeclaration'; data: InterfaceDeclaration }
  | { type: 'TypeAliasDeclaration'; data: TypeAliasDeclaration }
  /* JS */
  | { type: 'Return'; data: JSNode }
  | { type: 'Literal'; data: Literal }
  | { type: 'Identifier'; data: string[] }
  | { type: 'ImportDeclaration'; data: ImportDeclaration }
  | { type: 'ImportSpecifier'; data: ImportSpecifier }
  | { type: 'ImportDefaultSpecifier'; data: string }
  | { type: 'ClassDeclaration'; data: ClassDeclaration }
  | { type: 'MethodDefinition'; data: MethodDefinition }
  | { type: 'FunctionExpression'; data: FunctionExpression }
  | { type: 'ArrowFunctionExpression'; data: FunctionExpression }
  | { type: 'CallExpression'; data: CallExpression }
  | { type: 'MemberExpression'; data: MemberExpression }
  | { type: 'JSXAttribute'; data: JSXAttribute }
  | { type: 'JSXElement'; data: JSXElement }
  | { type: 'JSXExpressionContainer'; data: JSNode }
  | { type: 'JSXSpreadAttribute'; data: JSNode }
  | { type: 'SpreadElement'; data: JSNode }
  | { type: 'VariableDeclaration'; data: JSNode }
  | { type: 'AssignmentExpression'; data: AssignmentExpression }
  | { type: 'BinaryExpression'; data: BinaryExpression }
  | { type: 'UnaryExpression'; data: UnaryExpression }
  | { type: 'IfStatement'; data: IfStatement }
  | { type: 'ConditionalExpression'; data: ConditionalExpression }
  | { type: 'Property'; data: Property }
  | { type: 'ExportDefaultDeclaration'; data: JSNode }
  | { type: 'ExportNamedDeclaration'; data: JSNode }
  | { type: 'Block'; data: JSNode[] }
  | { type: 'Program'; data: JSNode[] }
  | { type: 'LineEndComment'; data: LineEndComment }
  | { type: 'Empty' }
  | { type: 'Unknown' }

// /* Children are mapped first */
// let rec map = (f: node => node, node) =>
//   switch (node) {
//   | Return(value) => f(Return(value |> map(f)))
//   | Literal(_)
//   | StringLiteral(_)
//   | Identifier(_)
//   | ImportDeclaration(_)
//   | ImportSpecifier(_)
//   | ImportDefaultSpecifier(_) => f(node)
//   | JSXExpressionContainer(value) =>
//     f(JSXExpressionContainer(value |> map(f)))
//   | JSXSpreadAttribute(value) => JSXSpreadAttribute(f(value))
//   | SpreadElement(value) => SpreadElement(f(value))
//   | ClassDeclaration(o) =>
//     f(
//       ClassDeclaration({
//         id: o.id,
//         superClass: o.superClass,
//         body: o.body |> List.map(map(f)),
//       }),
//     )
//   | MethodDefinition(o) =>
//     f(MethodDefinition({key: o.key, value: o.value |> map(f)}))
//   | FunctionExpression(o) =>
//     f(
//       FunctionExpression({
//         id: o.id,
//         params: o.params |> List.map(map(f)),
//         body: o.body |> List.map(map(f)),
//       }),
//     )
//   | ArrowFunctionExpression(o) =>
//     f(
//       ArrowFunctionExpression({
//         id: o.id,
//         params: o.params |> List.map(map(f)),
//         body: o.body |> List.map(map(f)),
//       }),
//     )
//   | CallExpression(o) =>
//     f(
//       CallExpression({
//         callee: o.callee |> map(f),
//         arguments: o.arguments |> List.map(map(f)),
//       }),
//     )
//   | JSXAttribute(o) =>
//     f(JSXAttribute({name: o.name, value: o.value |> map(f)}))
//   | JSXElement(o) =>
//     f(
//       JSXElement({
//         tag: o.tag,
//         attributes: o.attributes |> List.map(map(f)),
//         content: o.content |> List.map(map(f)),
//       }),
//     )
//   | VariableDeclaration(value) => f(VariableDeclaration(value |> map(f)))
//   | AssignmentExpression(o) =>
//     f(
//       AssignmentExpression({
//         left: o.left |> map(f),
//         right: o.right |> map(f),
//       }),
//     )
//   | BinaryExpression(o) =>
//     f(
//       BinaryExpression({
//         left: o.left |> map(f),
//         operator: o.operator,
//         right: o.right |> map(f),
//       }),
//     )
//   | UnaryExpression(o) =>
//     f(
//       UnaryExpression({
//         prefix: o.prefix,
//         operator: o.operator,
//         argument: o.argument |> map(f),
//       }),
//     )
//   | IfStatement(o) =>
//     f(
//       IfStatement({
//         test: o.test |> map(f),
//         consequent: o.consequent |> List.map(map(f)),
//         alternate: o.alternate |> List.map(map(f)),
//       }),
//     )
//   | ConditionalExpression(o) =>
//     f(
//       ConditionalExpression({
//         test: o.test |> map(f),
//         consequent: o.consequent |> map(f),
//         alternate: o.alternate |> map(f),
//       }),
//     )
//   | ArrayLiteral(body) => f(ArrayLiteral(body |> List.map(map(f))))
//   | ObjectLiteral(body) => f(ObjectLiteral(body |> List.map(map(f))))
//   | Property(o) =>
//     f(
//       Property({
//         key: o.key |> map(f),
//         value:
//           switch (o.value) {
//           | Some(value) => Some(value |> map(f))
//           | None => None
//           },
//       }),
//     )
//   | ExportDefaultDeclaration(value) =>
//     f(ExportDefaultDeclaration(value |> map(f)))
//   | ExportNamedDeclaration(value) =>
//     f(ExportNamedDeclaration(value |> map(f)))
//   | Block(body) => f(Block(body |> List.map(map(f))))
//   | Program(body) => f(Program(body |> List.map(map(f))))
//   | LineEndComment(o) =>
//     f(LineEndComment({comment: o.comment, line: o.line |> map(f)}))
//   | Empty
//   | Unknown => f(node)
//   };

// /* Takes an expression like `a === true` and converts it to `a` */
// let optimizeTruthyBinaryExpression = node => {
//   let booleanValue = sub =>
//     switch (sub) {
//     | Literal(value) => value.data |> Json.Decode.optional(Json.Decode.bool)
//     | _ => (None: option(bool))
//     };
//   switch (node) {
//   | BinaryExpression(o) =>
//     switch (booleanValue(o.left), o.operator, booleanValue(o.right)) {
//     | (_, Eq, Some(true)) => o.left
//     | (Some(true), Eq, _) => o.right
//     | _ => node
//     }
//   | _ => node
//   };
// };

// /* Renamed "layer.View.backgroundColor" to something JS-safe and nice looking */
// let renameIdentifiers = node =>
//   switch (node) {
//   | Identifier(["parameters", ...tail]) =>
//     Identifier([
//       "this",
//       "props",
//       ...tail |> List.map(Format.safeVariableName),
//     ])
//   | Identifier(["layers", ...tail]) =>
//     Identifier([
//       tail |> List.map(Format.safeVariableName) |> Format.joinWith("$"),
//     ])
//   | Identifier(parts) =>
//     Identifier(parts |> List.map(Format.safeVariableName))
//   | _ => node
//   };

// let optimize = node => node |> map(optimizeTruthyBinaryExpression);

// let prepareForRender = node => node |> map(renameIdentifiers);
