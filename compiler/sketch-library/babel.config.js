module.exports = {
  presets: [
    '@babel/react',
    [
      '@babel/env',
      {
        targets: {
          node: 'current',
        },
      },
    ],
  ],
}
