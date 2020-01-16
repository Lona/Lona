const xml = `<?xml version="1.0"?>
<FunctionCallExpression>
  <IdentifierExpression name="ThemedColor"/>
  <Argument label="light">
    <Literal type="Color" value="pink"/>
  </Argument>
  <Argument label="dark">
    <Literal type="Color" value="purple"/>
  </Argument>
</FunctionCallExpression>`

const code = `ThemedColor(light: #color(css: "pink"), dark: #color(css: "purple"))`

const json = {
  data: {
    arguments: [
      {
        data: {
          expression: {
            data: {
              id: '0',
              literal: {
                data: {
                  id: '0',
                  value: 'pink',
                },
                type: 'color',
              },
            },
            type: 'literalExpression',
          },
          id: '0',
          label: 'light',
        },
        type: 'argument',
      },
      {
        data: {
          expression: {
            data: {
              id: '0',
              literal: {
                data: {
                  id: '0',
                  value: 'purple',
                },
                type: 'color',
              },
            },
            type: 'literalExpression',
          },
          id: '0',
          label: 'dark',
        },
        type: 'argument',
      },
      {
        data: {
          id: '0',
        },
        type: 'placeholder',
      },
    ],
    expression: {
      data: {
        id: '0',
        identifier: {
          id: '0',
          isPlaceholder: false,
          string: 'ThemedColor',
          type: 'identifier',
        },
      },
      type: 'identifierExpression',
    },
    id: '0',
  },
  type: 'functionCallExpression',
}

module.exports = { json, xml, code }
