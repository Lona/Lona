const traverse = require("@babel/traverse").default;

function find(path, type, predicate = x => !!x) {
  let results = [];

  traverse(
    ast,
    {
      [type](path) {
        if (!predicate(path)) return;
        results.push(path);
      }
    },
    path
  );

  return results;
}

function findNested(path, entries = []) {
  if (entries.length === 0) return [];

  return entries.reduce(
    (paths, entry) => {
      const { type, predicate } = entry;
      const results = paths.map(c => this.find(c, type, predicate));
      return [].concat(...results);
    },
    [path]
  );
}

module.exports = { find, findNested };
