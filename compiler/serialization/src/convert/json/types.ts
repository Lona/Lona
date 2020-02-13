import stringify from 'json-stable-stringify'

export function print(ast: any) {
  return stringify(ast, { space: '  ' })
}

export function parse(contents: string) {
  return JSON.parse(contents)
}
