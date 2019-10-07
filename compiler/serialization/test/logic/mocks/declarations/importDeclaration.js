const xml = `<?xml version="1.0"?>
<Declaration.ImportDeclaration name="Prelude"/>`

const json = {
  data: {
    content: {
      data: {
        id: '0',
        name: {
          id: '0',
          name: 'Prelude',
        },
      },
      type: 'importDeclaration',
    },
    id: '0',
  },
  type: 'declaration',
}

const code = 'import Prelude'

module.exports = { json, xml, code }
