// If we can tell we don't need a ternary expression, remove it!
//
// let x = inverse ? 1 : undefined;
// let y = x !== undefined ? x : 2;
//
// should become:
//
// let y = inverse ? 1 : 2;
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  root
    .find(j.ClassMethod, { key: { name: 'render' } })
    .find(j.VariableDeclarator)
    .forEach((path) => {
      const left = path.get('id').get('name').value;
      const conditional = j(path).find(j.ConditionalExpression);

      if (conditional.size() === 0) return;

      const test = conditional.get('test').value;
      const right = conditional.get('alternate').get('name').value;

      if (right !== 'undefined') return;

      // let x = inverse ? 1 : undefined;
      // let y = x !== undefined ? x : 2;
      //
      // should become:
      //
      // let y = inverse ? 1 : 2;
      j(path)
        .closest(j.ClassMethod)
        .find(j.ConditionalExpression, {
          test: {
            left: { name: left },
            operator: '!==',
            right: { name: 'undefined' },
          },
          consequent: {
            name: left,
          },
        })
        .forEach((conditionalPath) => {
          const replacement = j.conditionalExpression(
            test,
            conditional.get('consequent').value,
            conditionalPath.get('alternate').value,
          );

          j(conditionalPath).replaceWith(replacement);

          // TODO need to make sure no reassignment?
          j(path).remove();
        });

      // let x = inverse ? 1 : undefined;
      // prop={x}
      //
      // should become:
      //
      // prop={inverse ? 1 : undefined}
      j(path)
        .closest(j.ClassMethod)
        .find(j.Identifier, {
          name: left,
        })
        .forEach((identifierPath) => {
          const parentType = j(identifierPath.parent).get('type').value;

          // Ignore the identifier in the case it's defined
          if (parentType === 'VariableDeclarator') {
            return;
          }

          j(identifierPath).replaceWith(conditional.get().value);
        });
    });

  return root.toSource();
};
