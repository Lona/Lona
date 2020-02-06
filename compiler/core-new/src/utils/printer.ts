import { doc, Doc } from 'prettier'
export { Doc } from 'prettier'

export const builders = doc.builders

export function group(x: Doc[] | Doc): Doc {
  if (Array.isArray(x)) {
    return builders.group(builders.concat(x))
  }
  return builders.group(x)
}
export function indent(x: Doc[] | Doc): Doc {
  if (Array.isArray(x)) {
    return builders.indent(builders.concat(x))
  }
  return builders.indent(x)
}

export function join(x: Doc[], separator: Doc | Doc[]): Doc {
  if (Array.isArray(separator)) {
    return builders.join(builders.concat(separator), x)
  }
  return builders.join(separator, x)
}

export function prefixAll(x: Doc[], prefix: Doc): Doc[] {
  return x.map(y => builders.concat([prefix, y]))
}

export function print(document: Doc, options: doc.printer.Options) {
  return doc.printer.printDocToString(document, options).formatted
}
