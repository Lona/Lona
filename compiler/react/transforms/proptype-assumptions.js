const countAssignments = require('./helpers/countAssignments');
const getProps = require('./helpers/getProps');

module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  const { propTypes } = getProps(j, root);

  root.find(j.ClassMethod, { key: { name: 'render' } }).forEach((path) => {
    const assignmentCount = countAssignments(j, path);

    j(path)
      .find(j.LogicalExpression, {
        operator: '&&',
      })
      // Make sure we never reassign this variable. If we do, we don't want
      // to continue with this replacement.
      .filter((expressionPath) => {
        const name = expressionPath.get('left').get('name').value;
        return !(name in assignmentCount);
      })
      .filter((expressionPath) => {
        const name = expressionPath.get('left').get('name').value;
        let found = false;

        j(path)
          .find(j.VariableDeclarator, { id: { name } })
          // Assume at most one declarator
          .forEach((declarator) => {
            // Match: `test ? true : undefined`
            const conditional = j(declarator).find(j.ConditionalExpression, {
              consequent: { value: true },
              alternate: { name: 'undefined' },
            });

            if (conditional.size() === 0) return;

            const test = conditional.get('test').get('name').value;

            if (propTypes[test] !== 'bool') return;

            found = true;
          });

        return found;
      })
      .forEach((expressionPath) => {
        const name = expressionPath.get('left').get('name').value;
        const newName = j(path)
          .find(j.VariableDeclarator, { id: { name } })
          .find(j.ConditionalExpression)
          .get('test')
          .get('name').value;

        const replacement = j.identifier(newName);
        j(expressionPath.get('left')).replaceWith(replacement);
      });
  });

  return root.toSource();
};
