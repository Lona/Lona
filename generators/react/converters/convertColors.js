/* eslint no-param-reassign: 0 */
module.exports = function convertColors(data = {}) {
  const { colors = [] } = data;

  const converted = colors.reduce((result, item) => {
    const { id, value } = item;
    result[id] = value;
    return result;
  }, {});

  return converted;
};
