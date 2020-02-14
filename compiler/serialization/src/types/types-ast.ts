export type NativeType = {
  case: 'native'
  data: {
    name: string
    parameters: { name: string }[]
  }
}

export type GenericParam = {
  case: 'generic'
  name: string
}

export type TypeParam = {
  case: 'type'
  name: string
  substitutions: { generic: string; instance: string }[]
}

export type Param = GenericParam | TypeParam

export type NormalCase = {
  case: 'normal'
  name: string
  params: { value: Param }[]
}

export type RecordCase = {
  case: 'record'
  name: string
  params: { key: string; value: Param }[]
}

export type Case = NormalCase | RecordCase

export type UserType = {
  case: 'type'
  data: {
    name: string
    cases: Case[]
  }
}

export type Type = NativeType | UserType

export type Root = {
  types: Type[]
}
