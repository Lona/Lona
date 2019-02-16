const compiler = require('./compiler')

test('Should compile a component', () => {
  return compiler(
    '../../../examples/test/components/NestedButtons.component'
  ).then(stats => {
    const output = stats
      .toJson()
      .modules.find(x =>
        x.reasons.some(
          y =>
            y.userRequest ===
            './../../../examples/test/components/NestedButtons.component'
        )
      )

    expect(output.modules.map(x => x.source)).toMatchSnapshot()
  })
})
