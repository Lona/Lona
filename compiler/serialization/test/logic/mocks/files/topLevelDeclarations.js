const xml = `<?xml version="1.0"?>
<Declarations>
  <ImportDeclaration name="Prelude"/>
  <Variable name="x" type="Number" value="123"/>
  <Namespace name="Test">
    <Variable name="b" type="Boolean" value="false"/>
  </Namespace>
</Declarations>`

const code = `import Prelude

let x: Number = 123

enum Test {
  static let b: Boolean = false
}`

const json = {
  data: {
    declarations: [
      {
        data: {
          id: '0',
          name: {
            id: '0',
            name: 'Prelude',
            type: 'pattern',
          },
        },
        type: 'importDeclaration',
      },
      {
        data: {
          annotation: {
            data: {
              genericArguments: [],
              id: '0',
              identifier: {
                id: '0',
                isPlaceholder: false,
                string: 'Number',
                type: 'identifier',
              },
            },
            type: 'typeIdentifier',
          },
          id: '0',
          initializer: {
            data: {
              id: '0',
              literal: {
                data: {
                  id: '0',
                  value: 123,
                },
                type: 'number',
              },
            },
            type: 'literalExpression',
          },
          name: {
            id: '0',
            name: 'x',
            type: 'pattern',
          },
        },
        type: 'variable',
      },
      {
        data: {
          declarations: [
            {
              data: {
                annotation: {
                  data: {
                    genericArguments: [],
                    id: '0',
                    identifier: {
                      id: '0',
                      isPlaceholder: false,
                      string: 'Boolean',
                      type: 'identifier',
                    },
                  },
                  type: 'typeIdentifier',
                },
                id: '0',
                initializer: {
                  data: {
                    id: '0',
                    literal: {
                      data: {
                        id: '0',
                        value: false,
                      },
                      type: 'boolean',
                    },
                  },
                  type: 'literalExpression',
                },
                name: {
                  id: '0',
                  name: 'b',
                  type: 'pattern',
                },
              },
              type: 'variable',
            },
            {
              data: {
                id: '0',
              },
              type: 'placeholder',
            },
          ],
          id: '0',
          name: {
            id: '0',
            name: 'Test',
            type: 'pattern',
          },
        },
        type: 'namespace',
      },
      {
        data: {
          id: '0',
        },
        type: 'placeholder',
      },
    ],
    id: '0',
  },
  type: 'topLevelDeclarations',
}

module.exports = { json, xml, code }
