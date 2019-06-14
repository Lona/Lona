type identifier = string
/* Literals */
and recordEntry = {
  key: string,
  value: expression,
}
and literal =
  | Boolean(bool)
  | Number(float)
  | String(string)
  | Array(list(expression))
  | Record(list(recordEntry))
/* Type Annotations */
and typeAnnotation = {
  name: identifier,
  parameters: list(typeAnnotation),
}
and variantCase = {
  name: identifier,
  associatedData: list(typeAnnotation),
}
and variantType = {cases: list(variantCase)}
and recordTypeEntry = {
  key: string,
  value: typeAnnotation,
}
and recordType = {entries: list(recordTypeEntry)}
/* Expressions */
and literalExpression = {literal}
and identifierExpression = {name: identifier}
and memberExpression = {
  expression,
  memberName: identifier,
}
and functionCallExpression = {
  expression,
  arguments: list(expression),
}
and functionParameter = {
  name: identifier,
  annotation: option(typeAnnotation),
}
and functionExpression = {
  parameters: list(functionParameter),
  returnType: option(typeAnnotation),
  body: list(declaration),
}
and switchCase = {
  pattern: expression,
  body: list(declaration),
}
and switchExpression = {
  pattern: expression,
  cases: list(switchCase),
}
and expression =
  | LiteralExpression(literalExpression)
  | IdentifierExpression(identifierExpression)
  | MemberExpression(memberExpression)
  | FunctionCallExpression(functionCallExpression)
  | FunctionExpression(functionExpression)
  | SwitchExpression(switchExpression)
/* Declarations */
and typeDeclarationValue =
  | VariantType(variantType)
  | RecordType(recordType)
and typeDeclaration = {
  name: typeAnnotation,
  value: typeDeclarationValue,
}
and quantifiedTypeAnnotation = {
  forall: list(string),
  annotation: typeAnnotation,
}
and variableDeclaration = {
  name: identifier,
  quantifiedAnnotation: option(quantifiedTypeAnnotation),
  initializer_: expression,
}
and moduleDeclaration = {
  name: identifier,
  declarations: list(declaration),
}
and declaration =
  | Type(list(typeDeclaration))
  | Variable(list(variableDeclaration))
  | Module(moduleDeclaration)
  | Open(list(identifier))
  | Expression(expression);

let functionTypeAnnotation = (args, ret): typeAnnotation => {
  name: "=>",
  parameters: [args, ret],
};

let tuple2TypeAnnotation = (p0, p1): typeAnnotation => {
  name: "(,)",
  parameters: [p0, p1],
};

let tuple3TypeAnnotation = (p0, p1, p2): typeAnnotation => {
  name: "(,,)",
  parameters: [p0, p1, p2],
};

let tupleNTypeAnnotation = parameters: typeAnnotation => {
  name: "(" ++ Js.String.repeat(List.length(parameters), ",") ++ ")",
  parameters,
};