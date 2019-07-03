const xml = `<?xml version="1.0"?>
<Declarations>
  <Record name="ThemedColor">
    <Variable name="light" type="Color" value="white"/>
    <Variable name="dark" type="Color" value="black"/>
  </Record>
</Declarations>`

const json = {
  data: {
    declarations: [
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
                      string: 'Color',
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
                        value: 'white',
                      },
                      type: 'color',
                    },
                  },
                  type: 'literalExpression',
                },
                name: {
                  id: '0',
                  name: 'light',
                },
              },
              type: 'variable',
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
                      string: 'Color',
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
                        value: 'black',
                      },
                      type: 'color',
                    },
                  },
                  type: 'literalExpression',
                },
                name: {
                  id: '0',
                  name: 'dark',
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
          genericParameters: [],
          id: '0',
          name: {
            id: '0',
            name: 'ThemedColor',
          },
        },
        type: 'record',
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

module.exports = { json, xml }
