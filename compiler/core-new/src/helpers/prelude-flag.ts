import * as path from 'path'
import * as fs from 'fs'
import * as LogicAST from './logic-ast'

let cachedLibraries: {
  records: LogicAST.AST.RecordDeclaration[]
  namespaces: LogicAST.AST.NamespaceDeclaration[]
  enumerations: LogicAST.AST.EnumerationDeclaration[]
}
const libraries = () => {
  if (cachedLibraries) {
    return cachedLibraries
  }

  const preludePath = path.join(__dirname, '../../static/logic')
  const preludeLibs = fs.readdirSync(preludePath)

  const libraries: LogicAST.AST.Program[] = preludeLibs.map(
    x =>
      LogicAST.makeProgram(
        JSON.parse(fs.readFileSync(path.join(preludePath, x), 'utf8'))
      ) as LogicAST.AST.Program
  )

  cachedLibraries = {
    records: [],
    namespaces: [],
    enumerations: [],
  }

  libraries.forEach(x => {
    x.data.block.forEach(y => {
      if (y.type !== 'declaration') {
        return
      }
      const declaration = y.data.content
      switch (declaration.type) {
        case 'enumeration': {
          cachedLibraries.enumerations.push(declaration)
          break
        }
        case 'namespace': {
          cachedLibraries.namespaces.push(declaration)
          break
        }
        case 'record': {
          cachedLibraries.records.push(declaration)
          break
        }
        case 'placeholder':
        case 'importDeclaration': {
          // we don't care about those
          break
        }
        default: {
          console.log(declaration)
          throw new Error('prelude not handled')
        }
      }
    })
  })

  return cachedLibraries
}

export const flagForPreludeDependencies = (node: LogicAST.AST.SyntaxNode) => {
  const libs = libraries()

  const dependencies: {
    [id: string]:
      | LogicAST.AST.RecordDeclaration
      | LogicAST.AST.EnumerationDeclaration
      | LogicAST.AST.NamespaceDeclaration
  } = {}

  switch (node.type) {
    case 'functionCallExpression': {
      // we don't LogicAST on all functionCallExpression because it would call it
      // for a memberExpression we have already handled
      node.data.arguments.forEach(x =>
        Object.assign(dependencies, flagForPreludeDependencies(x))
      )
      if (node.data.expression.type === 'identifierExpression') {
        const identifier = node.data.expression.data.identifier
        if (identifier.isPlaceholder) {
          break
        }
        const matchingRecord = libs.records.find(
          x => x.data.name.name === identifier.string
        )
        if (matchingRecord) {
          dependencies[node.data.id] = matchingRecord
        }
        break
      }
      if (
        node.data.expression.type === 'memberExpression' &&
        node.data.expression.data.expression.type === 'identifierExpression'
      ) {
        const { expression, memberName } = node.data.expression.data
        if (
          expression.data.identifier.isPlaceholder ||
          memberName.isPlaceholder
        ) {
          break
        }
        const potentialMatchingEnum = libs.enumerations.find(
          x => x.data.name.name === expression.data.identifier.string
        )
        if (
          potentialMatchingEnum &&
          potentialMatchingEnum.data.cases.find(
            x =>
              x.type === 'enumerationCase' &&
              x.data.name.name === memberName.string &&
              x.data.associatedValueTypes.some(y => y.type !== 'placeholder')
          )
        ) {
          dependencies[node.data.id] = potentialMatchingEnum
          break
        }

        const potentialMatchingNamespace = libs.namespaces.find(
          x => x.data.name.name === expression.data.identifier.string
        )
        if (
          potentialMatchingNamespace &&
          potentialMatchingNamespace.data.declarations.find(
            x => x.type === 'function' && x.data.name.name === memberName.string
          )
        ) {
          dependencies[node.data.id] = potentialMatchingNamespace
          break
        }

        if (potentialMatchingEnum) {
          // TODO: use reporters
          console.warn(
            `Couldn't find prelude dynamic enum case for "${expression.data.identifier.string}.${memberName.string}"`
          )
        }
        if (potentialMatchingNamespace) {
          // TODO: use reporters
          console.warn(
            `Couldn't find prelude namespaced function for "${expression.data.identifier.string}.${memberName.string}"`
          )
        }
      }
      break
    }
    case 'memberExpression': {
      if (node.data.expression.type !== 'identifierExpression') {
        break
      }
      const { expression, memberName } = node.data
      if (
        expression.data.identifier.isPlaceholder ||
        memberName.isPlaceholder
      ) {
        break
      }

      const potentialMatchingEnum = libs.enumerations.find(
        x => x.data.name.name === expression.data.identifier.string
      )
      if (
        potentialMatchingEnum &&
        potentialMatchingEnum.data.cases.find(
          x =>
            x.type === 'enumerationCase' &&
            x.data.name.name === memberName.string &&
            x.data.associatedValueTypes.every(y => y.type === 'placeholder')
        )
      ) {
        dependencies[node.data.id] = potentialMatchingEnum
        break
      }

      const potentialMatchingNamespace = libs.namespaces.find(
        x => x.data.name.name === expression.data.identifier.string
      )
      if (
        potentialMatchingNamespace &&
        potentialMatchingNamespace.data.declarations.find(
          x => x.type === 'variable' && x.data.name.name === memberName.string
        )
      ) {
        dependencies[node.data.id] = potentialMatchingNamespace
        break
      }

      if (potentialMatchingEnum) {
        // TODO: use reporters
        console.warn(
          `Couldn't find prelude static enum case for "${expression.data.identifier.string}.${memberName.string}"`
        )
      }
      if (potentialMatchingNamespace) {
        // TODO: use reporters
        console.warn(
          `Couldn't find prelude namespaced variable for "${expression.data.identifier.string}.${memberName.string}"`
        )
      }
      break
    }
    default: {
      LogicAST.subNodes(node).forEach(x =>
        Object.assign(dependencies, flagForPreludeDependencies(x))
      )
    }
  }

  return dependencies
}
