// Remove variables that are assigned but never used
const countAssignments = require('./helpers/countAssignments');

module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  root.find(j.ClassMethod, { key: { name: 'render' } }).forEach((path) => {
    const assignmentCount = countAssignments(j, path);

    j(path).find(j.VariableDeclarator).forEach((declaratorPath) => {
      const name = declaratorPath.get('id').get('name').value;

      if (name === undefined) return;
      if (name in assignmentCount) return;

      const usages = j(path)
        .find(j.Identifier, {
          name,
        })
        .size();

      // The identifier is in the declarator, so 1 means that this variable
      // is declared but never used. Return if this isn't the case.
      if (usages !== 1) return;

      j(declaratorPath).remove();
    });
  });

  return root.toSource();
};
