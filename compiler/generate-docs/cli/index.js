#!/usr/bin/env node

const cli = require('yargs')
const didYouMean = require('./did-you-mean')

// eslint-disable-next-line no-unused-expressions
cli
  .scriptName('@lona/docs')
  .command(require('../commands/build').command)
  .usage('Usage: @lona/docs <command> [options]')
  .parserConfiguration({
    'boolean-negation': false,
  })
  .alias('h', 'help')
  .alias('v', 'version')
  .option('verbose', {
    default: false,
    type: 'boolean',
    describe: 'Turn on verbose output',
    global: true,
  })
  .option('no-color', {
    default: false,
    type: 'boolean',
    describe: 'Turn off the color in output',
    global: true,
  })
  .demandCommand(1, 'Pass --help to see all available commands and options.')
  .strict()
  .fail((msg, err, yargs) => {
    const availableCommands = yargs.getCommands().map(commandDescription => {
      const [command] = commandDescription
      return command.split(' ')[0]
    })
    const arg = process.argv.slice(2)[0]
    const suggestion = arg ? didYouMean(arg, availableCommands) : ''

    yargs.showHelp()
    console.log(suggestion)
    console.log(msg)
  }).argv
