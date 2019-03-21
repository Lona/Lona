// see https://github.com/FormidableLabs/prism-react-renderer#theming

export default {
  plain: {
    color: '#C5C8C6',
  },
  styles: [
    {
      types: ['comment', 'prolog', 'doctype', 'cdata'],
      style: {
        color: 'hsl(30, 20%, 50%)',
      },
    },
    {
      types: ['punctuation', 'namespace'],
      style: {
        opacity: 0.7,
      },
    },
    {
      types: ['property', 'tag', 'boolean', 'number', 'constant', 'symbol'],
      style: {
        color: '#08ABEA',
      },
    },
    {
      types: ['selector', 'attr-name'],
      style: {
        color: '#01B490',
      },
    },
    {
      types: ['string', 'char', 'builtin', 'inserted'],
      style: {
        color: '#3E57AB',
      },
    },
    {
      types: ['operator', 'entity', 'url', 'variable'],
      style: {
        color: '#626262',
      },
    },
    {
      types: ['atrule', 'attr-value', 'keyword'],
      style: {
        color: 'hsl(350, 40%, 70%)',
      },
    },
    {
      types: ['regex', 'important'],
      style: {
        color: '#e90',
      },
    },
    {
      types: ['entity'],
      style: {
        cursor: 'help',
      },
    },
    {
      types: ['deleted'],
      style: {
        color: 'red',
      },
    },
  ],
}
