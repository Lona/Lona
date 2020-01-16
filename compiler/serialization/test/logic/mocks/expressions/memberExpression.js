const xml = `<?xml version="1.0"?>
<MemberExpression name="primary">
  <IdentifierExpression name="Colors"/>
</MemberExpression>`

const code = `Colors.primary`

const json = {
  data: {
    expression: {
      data: {
        id: '0',
        identifier: {
          id: '0',
          isPlaceholder: false,
          string: 'Colors',
          type: 'identifier',
        },
      },
      type: 'identifierExpression',
    },
    id: '0',
    memberName: {
      id: '0',
      isPlaceholder: false,
      string: 'primary',
      type: 'identifier',
    },
  },
  type: 'memberExpression',
}

module.exports = { json, xml, code }
