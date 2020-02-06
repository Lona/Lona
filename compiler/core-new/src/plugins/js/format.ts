import snakeCase from 'lodash.snakecase'

export const enumName = (name: string) => snakeCase(name).toUpperCase()
export const enumCaseName = (name: string) => snakeCase(name).toUpperCase()
