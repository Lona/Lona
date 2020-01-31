import * as fs from 'fs'
import * as path from 'path'

import * as LogicAST from '../src/helpers/logic-ast'
import { build } from '../src/helpers/logic-scope'

const preludePath = path.join(__dirname, '../static/logic')
const preludeLibs = fs.readdirSync(preludePath)

const libraryFiles: LogicAST.AST.Program[] = preludeLibs.map(
  x =>
    LogicAST.makeProgram(
      JSON.parse(fs.readFileSync(path.join(preludePath, x), 'utf8'))
    ) as LogicAST.AST.Program
)

const preludeProgram = LogicAST.joinPrograms(libraryFiles)

const scopeContext = build(preludeProgram)

const hardcodedMapping = scopeContext._namespace.map
  .map<[string[], LogicAST.AST.SyntaxNode | void]>(x => [
    x.key,
    LogicAST.getNode(preludeProgram, x.value),
  ])
  .reduce(
    (prev, [key, node]) => {
      if (!node) {
        return prev
      }

      if (node.type === 'function' || node.type === 'record') {
        prev.functionCallExpression[key.join('.')] = node
      }
      if (node.type === 'variable') {
        prev.memberExpression[key.join('.')] = node
      }

      if (node.type === 'enumerationCase') {
        if (
          node.data.associatedValueTypes.some(x => x.type !== 'placeholder')
        ) {
          prev.functionCallExpression[key.join('.')] = node
        } else {
          prev.memberExpression[key.join('.')] = node
        }
      }

      return prev
    },
    { functionCallExpression: {}, memberExpression: {} }
  )

const syntaxNodeMapping = {
  functionCallExpression: 'FunctionCallExpressionExpression',
  memberExpression: 'MemberExpressionExpression',
}

fs.writeFileSync(
  path.join(__dirname, '../src/helpers/hardcoded-mapping.ts'),
  `// ⚠️ THIS FILE IS AUTO GENERATED. DO NOT MODIFY IT.

import { AST as LogicAST, flattenedMemberExpression } from './logic-ast'
import { EvaluationContext } from './logic-evaluate'

export type HardcodedMap<T, U extends any[]> = {
${Object.keys(hardcodedMapping)
  .map(
    k => `  ${k}: {
${Object.keys(hardcodedMapping[k])
  .map(
    x =>
      `    '${x}': (
      node: LogicAST.${syntaxNodeMapping[k]},
      ...args: U
    ) => T | void`
  )
  .join('\n')}
  }`
  )
  .join('\n')}
}

export const HandlePreludeFactory = <T, U extends any[]>(
  hardcodedMap: HardcodedMap<T, U>
) => (
  node: LogicAST.SyntaxNode,
  evaluationContext: void | EvaluationContext,
  ...args: U
): T | void => {
  if (!evaluationContext) {
    return
  }

  let matchedHardcodedNode: T | void

  Object.keys(hardcodedMap).forEach(
    (x: ${Object.keys(hardcodedMapping)
      .map(k => `'${k}'`)
      .join(' | ')}) => {
      if (node.type === x) {
        let memberExpression =
          'memberName' in node.data ? node : node.data.expression

        if (!evaluationContext.isFromInitialScope(memberExpression.data.id)) {
          return
        }

        const path = (flattenedMemberExpression(memberExpression) || [])
          .map(y => y.string)
          .join('.')

        if (hardcodedMap[x][path]) {
          matchedHardcodedNode = hardcodedMap[x][path](node, ...args)
        }
      }
    }
  )

  return matchedHardcodedNode
}
`
)
