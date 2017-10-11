const getProps = require('./helpers/getProps');

module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  const { propTypes } = getProps(j, root);

  Object.entries(propTypes).forEach(([key, value]) => {
    if (value === 'bool') {
      root
        .find(j.BinaryExpression, {
          left: { name: key },
          operator: '===',
          right: { value: true },
        })
        .replaceWith(key);
      root
        .find(j.BinaryExpression, {
          left: { name: key },
          operator: '===',
          right: { value: false },
        })
        .replaceWith(`!${key}`);
      root
        .find(j.BinaryExpression, {
          left: { name: key },
          operator: '!==',
          right: { value: true },
        })
        .replaceWith(`!${key}`);
      root
        .find(j.BinaryExpression, {
          left: { name: key },
          operator: '!==',
          right: { value: false },
        })
        .replaceWith(key);
    }
  });

  return root.toSource();
};
