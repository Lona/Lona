module.exports = function getProps(j, root) {
  const requiredProps = [];
  const optionalProps = [];
  const defaultProps = [];
  const propTypes = {};

  // Get required props
  root
    .find(j.ClassProperty, { key: { name: 'propTypes' } })
    .find(j.ObjectProperty)
    .forEach((path) => {
      const objectKey = j(path.node).get('key').get('name').value;
      const isRequired = j(path.node).find(j.Identifier, {
        name: 'isRequired',
      });

      const propType =
        j(path).get('value').get('object').get('property').get('name').value ||
        j(path).get('value').get('property').get('name').value;

      propTypes[objectKey] = propType;

      if (isRequired.size() > 0) {
        requiredProps.push(objectKey);
      } else {
        optionalProps.push(objectKey);
      }
    });

  // Get defaultProps
  root
    .find(j.ClassProperty, { key: { name: 'defaultProps' } })
    .find(j.ObjectProperty)
    .forEach((path) => {
      const objectKey = j(path.node).get('key').get('name').value;
      defaultProps.push(objectKey);
    });

  return {
    requiredProps,
    optionalProps,
    defaultProps,
    propTypes,
  };
};
