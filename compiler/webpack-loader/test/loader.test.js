/* globals test, expect */
const path = require('path')
const compiler = require('./compiler')

test('Should compile a component', () => {
  const relativePath =
    '../../../examples/test/components/NestedButtons.component'
  const absolutePath = path.resolve(__dirname, relativePath)
  return compiler(relativePath).then(stats => {
    let output

    function findModule(x) {
      if (x.name === absolutePath) {
        output = x
        return
      }
      if (x.modules) {
        x.modules.forEach(findModule)
      }
    }

    stats.toJson().modules.forEach(findModule)

    expect(output.source).toMatchSnapshot()
  })
})
