import * as fs from 'fs'
import * as path from 'path'
import { Config } from '../utils/config'
import * as LogicAST from './logic-ast'
import * as LogicScope from './logic-scope'
import * as LogicUnify from './logic-unify'
import * as LogicEvaluate from './logic-evaluate'
import uuid from '../utils/uuid'

function standardImportsProgram(): LogicAST.AST.Program {
  const libraryImports: LogicAST.AST.Statement[] = [
    'Prelude',
    'Color',
    'Shadow',
    'TextStyle',
  ].map(libraryName => ({
    type: 'declaration',
    data: {
      id: uuid(),
      content: {
        type: 'importDeclaration',
        data: {
          id: uuid(),
          name: {
            type: 'pattern',
            id: uuid(),
            name: libraryName,
          },
        },
      },
    },
  }))

  return {
    type: 'program',
    data: {
      id: uuid(),
      block: libraryImports,
    },
  }
}

function resolveImports(
  program: LogicAST.AST.Program,
  existingImports: string[] = []
): LogicAST.AST.Program {
  return {
    type: 'program',
    data: {
      id: uuid(),
      block: program.data.block
        .map(x => {
          if (x.type !== 'declaration') {
            return [x]
          }
          if (x.data.content.type !== 'importDeclaration') {
            return [x]
          }

          const libraryName = x.data.content.data.name.name

          if (existingImports.indexOf(libraryName) !== -1) {
            return [x]
          }

          const libraryPath = path.join(
            __dirname,
            '../../static/logic',
            `${libraryName}.logic`
          )
          const libraryExists = fs.existsSync(libraryPath)

          if (!libraryExists) {
            console.error(
              `Failed to find library ${libraryName} at path ${libraryPath}`
            )
            return [x]
          }

          const library = LogicAST.makeProgram(
            JSON.parse(fs.readFileSync(libraryPath, 'utf8'))
          )

          if (!library) {
            console.error(`Failed to import library ${libraryName}`)
            return [x]
          }

          const resolvedLibrary = resolveImports(
            library,
            existingImports.concat(libraryName)
          )

          return [x, ...resolvedLibrary.data.block]
        })
        .reduce((prev, x) => prev.concat(x), []),
    },
  }
}

export const generate = async (config: Config) => {
  let programNode = LogicAST.joinPrograms(
    Object.values(config.logicFiles).map(LogicAST.makeProgram)
  )

  programNode = LogicAST.joinPrograms([standardImportsProgram(), programNode])
  programNode = resolveImports(programNode)

  const scopeContext = LogicScope.build(programNode)

  const unificationContext = LogicUnify.makeUnificationContext(
    programNode,
    scopeContext
  )
  let substitution = LogicUnify.unify(unificationContext.constraints)

  let evaluationContext = LogicEvaluate.evaluate(
    programNode,
    programNode,
    scopeContext,
    unificationContext,
    substitution
  )

  return evaluationContext
}
