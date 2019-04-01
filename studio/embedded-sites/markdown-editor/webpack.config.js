const { resolve, join } = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const HtmlWebpackInlineSourcePlugin = require('html-webpack-inline-source-plugin')

const paths = {
  build: resolve(__dirname, 'build'),
  src: resolve(__dirname, 'src'),
  static: resolve(__dirname, 'static'),
}

const copyPlugin = new CopyWebpackPlugin([
  { from: paths.static, to: paths.build },
])

module.exports = {
  entry: './src/index.jsx',
  output: {
    filename: 'bundle.js',
    path: paths.build,
    publicPath: '',
  },
  devServer: {
    contentBase: paths.build,
    publicPath: '/',
    historyApiFallback: true,
    port: 3212,
  },
  devtool: 'source-map',
  module: {
    rules: [
      {
        test: /(.js|.jsx)$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              cacheDirectory: true,
            },
          },
        ],
      },
      {
        test: /\.pegjs$/,
        use: [
          {
            loader: 'pegjs-loader',
          },
        ],
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
  },
  plugins: [
    copyPlugin,
    new HtmlWebpackPlugin({
      filename: 'markdown-editor.html',
      template: join(paths.static, 'index.html'),
      inlineSource: '.(js|jsx|css)$',
    }),
    new HtmlWebpackInlineSourcePlugin(),
  ],
}
