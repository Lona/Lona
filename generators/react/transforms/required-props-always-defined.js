const getProps = require('./helpers/getProps');

module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  root.find(j.ClassDeclaration).forEach((classDeclarationPath) => {
    const { requiredProps, defaultProps } = getProps(
      j,
      j(classDeclarationPath),
    );

    defaultProps.forEach((name) => {
      root
        .find(j.BinaryExpression, {
          left: { name },
          operator: '!==',
          right: { name: 'undefined' },
        })
        .replaceWith('true');
    });

    requiredProps.forEach((name) => {
      j(classDeclarationPath)
        .find(j.ClassMethod, { key: { name: 'render' } })
        .forEach((path) => {
          const variableDeclaration = j(path.node).find(j.VariableDeclaration, {
            declarations: [{ init: { property: { name: 'props' } } }],
          });

          const objectProperty = variableDeclaration.find(j.ObjectProperty, {
            key: { name },
            value: { name },
          });

          if (variableDeclaration.size() === 0 && objectProperty.size() === 0) {
            return;
          }

          // if (variableDeclaration.get('declarations').value.length === 1) {
          //   variableDeclaration.remove();
          // } else {
          // objectProperty.remove();
          // }

          j(path)
            .find(j.BinaryExpression, {
              left: { name },
              operator: '!==',
              right: { name: 'undefined' },
            })
            .replaceWith('true');
        });
    });
  });

  return root.toSource();
};
