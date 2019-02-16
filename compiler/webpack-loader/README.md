# Lona Webpack Loader

Import Lona Components as React components.

## Installation

```bash
npm install -D lona-loader
```

## Usage

The Lona Webpack loader should be added to the same rule as the on you use to compile your normal React components.

Let's say you have the following rule:

```js
{
  test: /\.(m?jsx?)$/,
  exclude: /(node_modules)/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        presets: ['@babel/preset-env', '@babel/preset-react'],
      },
    },
  ],
}
```

Then your config should become like this:

```diff
{
- test: /\.(m?jsx?)$/,
+ test: /\.(m?jsx?|component)$/,
  exclude: /(node_modules)/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        presets: ['@babel/preset-env', '@babel/preset-react'],
      },
    },
+   {
+     loader: 'lona-loader',
+   }
  ],
}
```
