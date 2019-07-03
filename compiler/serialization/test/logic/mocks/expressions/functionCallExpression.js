const xml = `<?xml version="1.0"?>
<FunctionCallExpression>
  <IdentifierExpression name="ThemedColor"/>
  <FunctionCallArgument label="light">
    <LiteralExpression>
      <Color value="pink"/>
    </LiteralExpression>
  </FunctionCallArgument>
  <FunctionCallArgument label="dark">
    <LiteralExpression>
      <Color value="purple"/>
    </LiteralExpression>
  </FunctionCallArgument>
</FunctionCallExpression>`

const json = {
  data: {
    arguments: [
      {
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
      {
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
    ],
    expression: {
      data: {
        id: '0',
        identifier: {
          id: '0',
          isPlaceholder: false,
          string: 'ThemedColor',
        },
      },
      type: 'identifierExpression',
    },
    id: '0',
  },
  type: 'functionCallExpression',
}

module.exports = { json, xml }
