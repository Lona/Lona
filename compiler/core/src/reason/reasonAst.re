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
and expression =
  | LiteralExpression(literalExpression)
  | IdentifierExpression(identifierExpression)
  | MemberExpression(memberExpression)
  | FunctionCallExpression(functionCallExpression)
/* Declarations */
and typeDeclarationValue =
  | VariantType(variantType)
  | RecordType(recordType)
and typeDeclaration = {
  name: typeAnnotation,
  value: typeDeclarationValue,
}
and variableDeclaration = {
  name: identifier,
  annotation: option(typeAnnotation),
  initializer_: expression,
}
and moduleDeclaration = {
  name: identifier,
  declarations: list(declaration),
}
and declaration =
  | Type(list(typeDeclaration))
  | Variable(list(variableDeclaration))
  | Module(moduleDeclaration);