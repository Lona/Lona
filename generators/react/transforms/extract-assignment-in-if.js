// If we have a variable x, which is only assigned to once, in an if block:
//
// if (inverse) {
//   x = 123;
// }
//
// we should rewrite this as:
//
// x = inverse ? 123 : undefined;
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  const assignmentCount = {};

  root
    .find(j.ClassMethod, { key: { name: 'render' } })
    .find(j.AssignmentExpression)
    // Count the number of times we assign to each variable name
    .forEach((path) => {
      const left = j(path).get('left').get('name').value;
      assignmentCount[left] =
        left in assignmentCount ? assignmentCount[left] + 1 : 1;
    })
    .forEach((path) => {
      const left = j(path).get('left').get('name').value;

      if (assignmentCount[left] !== 1) return;

      const right = j(path).get('right').value;
      const ifStatement = j(path).closest(j.IfStatement);

      if (ifStatement.size() === 0) return;

      const expr = j(path);
      expr.remove();

      const source = j.assignmentExpression(
        '=',
        j.identifier(left),
        j.conditionalExpression(
          ifStatement.get('test').value,
          right,
          j.identifier('undefined'),
        ),
      );
      ifStatement.insertBefore(j(source).toSource());
    });

  return root.toSource();
};
