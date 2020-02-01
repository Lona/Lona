export function assertNever(x: never): never {
  throw new Error('Unknown type: ' + x['type'])
}
