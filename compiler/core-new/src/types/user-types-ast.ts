export type Reference = 'URL' | 'Color' | string

export type Named = {
  name: 'Named'
  alias: string
  of: Type
}

export type ResolvedEnum = {
  name: 'Enum' | 'Variant'
  cases: { tag: string; ltype: Type }[]
}

export type Enum = {
  name: 'Enum' | 'Variant'
  cases?: (string | void)[]
  case?: string
  type?: Type
}

export type Function = {
  name: 'Function'
  parameters?: { label: string; ltype: Type }[]
  returnType?: Type
}

export type Array = {
  name: 'Array'
  of: Type
}

export type Type = Reference | Named | Enum | Function | Array

export type TypesFile = {
  types: Type[]
}

export function dereference(x: Reference): Reference | Named {
  if (x === 'URL') {
    return {
      name: 'Named',
      alias: 'URL',
      of: 'String',
    }
  }
  if (x === 'Color') {
    return {
      name: 'Named',
      alias: 'Color',
      of: 'String',
    }
  }
  return x
}

export function resolveEnum(x: Enum): ResolvedEnum {
  return {
    name: x.name,
    cases: x.cases
      ? x.cases.map(y =>
          y ? { tag: y, ltype: 'Unit' } : { tag: x.case, ltype: x.type }
        )
      : [],
  }
}
