let id = 0
const nextId = () => ++id // eslint-disable-line

module.exports = function displayName(Component) {
  return Component.displayName || Component.name || `UnknownSymbol${nextId()}`
}
