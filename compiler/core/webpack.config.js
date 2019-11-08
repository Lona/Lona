const { resolve, join } = require('path')
const webpack = require('webpack')
const CopyWebpackPlugin = require('copy-webpack-plugin')

const paths = {
  build: resolve(__dirname, 'build'),
  src: resolve(__dirname, 'src'),
  nodeModules: resolve(__dirname, 'node_modules'),
}

const copyPlugin = new CopyWebpackPlugin([
  {
    from: join(paths.src, 'static'),
    to: join(paths.build, 'static'),
  },
  {
    from: join(paths.src, 'bin.js'),
    to: join(paths.build, 'bin.js'),
  },
  {
    from: join(
      paths.nodeModules,
      '@lona/serialization/build/pegjs/logic.swift.pegjs'
    ),
    to: join(paths.build, 'logic.swift.pegjs'),
  },
])

module.exports = [
  {
    mode: 'production',
    entry: './src/main.bs.js',
    output: {
      path: paths.build,
      filename: 'index.js',
    },
    target: 'node',
    node: {
      __dirname: false,
    },
    plugins: [
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify('production'),
      }),
      copyPlugin,
    ],
    module: {
      rules: [
        {
          test: /\.m?js$/,
          exclude: /(node_modules)/,
          use: {
            loader: 'babel-loader',
            options: {
              plugins: ['@babel/plugin-proposal-object-rest-spread'],
            },
          },
        },
      ],
    },
  },
  // {
  //   mode: "production",
  //   entry: "./src/api.js",
  //   output: {
  //     filename: "./build/api.js",
  //     library: "lonac",
  //     libraryTarget: "umd"
  //   },
  //   resolve: {
  //     extensions: [".js"],
  //     alias: {
  //       fs: "memfs"
  //     }
  //   },
  //   node: {
  //     module: "empty"
  //   },
  //   plugins: [
  //     new webpack.DefinePlugin({
  //       "process.env.NODE_ENV": JSON.stringify("production")
  //     })
  //   ]
  // }
]
