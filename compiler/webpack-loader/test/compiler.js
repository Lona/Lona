const path = require('path')
const webpack = require('webpack') // eslint-disable-line
const Memoryfs = require('memory-fs') // eslint-disable-line

module.exports = (fixture, options = {}) => {
  const compiler = webpack({
    context: __dirname,
    entry: `./${fixture}`,
    output: {
      path: path.resolve(__dirname),
      filename: 'bundle.js',
    },
    module: {
      rules: [
        {
          test: /\.(m?jsx?|component)$/,
          exclude: /(node_modules|bower_components)/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: ['@babel/preset-env', '@babel/preset-react'],
              },
            },
            {
              loader: path.resolve(__dirname, '../lib/loader.js'),
              options,
            },
          ],
        },
      ],
    },
    resolve: {
      modules: ['node_modules', path.resolve(__dirname, '../node_modules')],
    },
  })

  compiler.outputFileSystem = new Memoryfs()

  return new Promise((resolve, reject) => {
    compiler.run((err, stats) => {
      if (err || stats.hasErrors()) reject(err || stats.toJson().errors[0])

      resolve(stats)
    })
  })
}
