type document = {
  prolog,
  element,
}
and prolog = {xmlDecl: option(xmlDecl)}
and xmlDecl = {
  version: string,
  encoding: option(string),
}
and element = {
  tag: string,
  attributes: list(attribute),
  content: list(content),
}
and content =
  | Empty
  | Comment(comment)
  | CharData(charData)
  | Element(element)
and attribute = {
  name: string,
  value: string,
}
and comment = string
and charData = string;

type node = document;