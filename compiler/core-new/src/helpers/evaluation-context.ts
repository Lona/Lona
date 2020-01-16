import * as fs from 'fs'
import * as path from 'path'
import * as serialization from '@lona/serialization'
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

          const libraryExists = fs.existsSync(
            path.join(__dirname, '../../static', `${libraryName}.logic`)
          )

          if (!libraryExists) {
            console.warn(`Failed to find library ${libraryName}`)
            return [x]
          }

          const library = LogicAST.makeProgram(
            JSON.parse(
              fs.readFileSync(
                path.join(__dirname, '../../static', `${libraryName}.logic`),
                'utf8'
              )
            )
          )

          if (!library) {
            console.warn(`Failed to import library ${libraryName}`)
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

export const generate = async (
  config: Config,
  fs: { readFile(filePath: string): Promise<string> }
) => {
  const logicFiles = await Promise.all(
    config.logicPaths
      .map(x => fs.readFile(x).then(data => serialization.decodeLogic(data)))
      .concat(
        config.tokenPaths.map(x =>
          fs.readFile(x).then(data => serialization.extractProgramAST(data))
        )
      )
  )

  let programNode = LogicAST.joinPrograms(logicFiles.map(LogicAST.makeProgram))

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
