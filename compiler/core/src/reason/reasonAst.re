type identifier = string
/* Literals */
and literal =
  | Boolean(bool)
  | Number(float)
  | String(string)
  | Array(list(expression))
/* Type Annotations */
and typeAnnotation = {
  name: identifier,
  parameters: list(typeAnnotation),
}
/* Expressions */
and literalExpression = {literal}
and identifierExpression = {name: identifier}
and memberExpression = {
  expression,
  memberName: identifierExpression,
}
and expression =
  | MemberExpression(memberExpression)
  | IdentifierExpression(identifierExpression)
  | LiteralExpression(literalExpression)
/* Declarations */
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
and typeDeclarationValue =
  | VariantType(variantType)
  | RecordType(recordType)
and typeDeclaration = {
  name: typeAnnotation,
  value: typeDeclarationValue,
}
and declaration =
  | TypeDeclaration(list(typeDeclaration));