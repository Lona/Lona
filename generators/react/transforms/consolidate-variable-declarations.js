// If we have:
//
// let x = undefined;
// x = 123;
//
// we should consolidate these into:
//
// let x = 123;
function hoistSingleAssignment(j, name, blockOfDefinition, variableDeclarator) {
  const definitionValue = variableDeclarator.find(j.Identifier, {
    name: 'undefined',
  });

  if (definitionValue.size() !== 1) return;

  const assigned = blockOfDefinition.find(j.AssignmentExpression, {
    left: { name },
  });

  // console.log('assignment', name);

  if (assigned.size() !== 1) return;

  const assignedValue = j(assigned.get('right'));
  // console.log('assigned value', assignedValue.toSource());

  definitionValue.replaceWith(assignedValue.toSource());
  assigned.remove();
}

// If we assign a temporary variable but only use it once:
//
// render() {
//   let { title } = this.props;
//   let titleText = title;
//   return <Text>{titleText}</Text>;
// }
//
// change this to:
//
// render() {
//   let { title } = this.props;
//   return <Text>{title}</Text>;
// }
//
// For now, we only do this if the assigned value is the name of a prop
function removeSingleAssignment(
  j,
  name,
  blockOfDefinition,
  variableDeclarator,
) {
  const propsDeclaration = blockOfDefinition
    .find(j.VariableDeclaration, {
      declarations: [{ init: { property: { name: 'props' } } }],
    })
    .find(j.ObjectProperty)
    .nodes()
    .map(node => node.value.name);

  const variableDeclaration = j(variableDeclarator.paths()[0].parent);

  const assignments = blockOfDefinition.find(j.AssignmentExpression, {
    left: { name },
  });

  // We assign to this variable so we can't remove it
  if (assignments.size() > 0) {
    return;
  }

  const assignedValue = variableDeclarator.get('init').value;

  // Make sure this is defined as a prop
  if (!propsDeclaration.includes(assignedValue)) {
    return;
  }

  variableDeclaration.remove();

  blockOfDefinition
    .find(j.Identifier, {
      name,
    })
    .replaceWith(assignedValue);
}

module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  root
    .find(j.ClassMethod, { key: { name: 'render' } })
    .find(j.JSXExpressionContainer)
    .find(j.Identifier)
    .forEach((path) => {
      const parentType = j(path.parent).get('type').value;

      // Check if this identifier is the object in a MemberExpression, since we
      // don't want to eliminate member expression objects, e.g. `fonts` in `fonts[...]`.
      if (
        parentType === 'MemberExpression' &&
        j(path.parent).get('object').value === path.node
      ) {
        return;
      }

      const name = path.node.name;

      if (name === 'undefined') return;

      const blockOfDefinition = j(path).closestScope().find(j.BlockStatement);
      const variableDeclarator = blockOfDefinition.find(j.VariableDeclarator, {
        id: { name },
      });

      if (variableDeclarator.size() !== 1) return;

      hoistSingleAssignment(j, name, blockOfDefinition, variableDeclarator);
      removeSingleAssignment(j, name, blockOfDefinition, variableDeclarator);
    });

  return root.toSource();
};
