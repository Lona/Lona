/* globals window */
function parseQueryParams(urlString) {
  const url = new URL(urlString)
  const params = [...url.searchParams.entries()]
  return params.reduce((result, item) => {
    const [key, value] = item
    result[key] = value
    return result
  }, {})
}

const rawParams = parseQueryParams(window.location.href)

let theme
try {
  theme = JSON.parse(rawParams.theme)
} catch (e) {
  theme = {}
}

export default {
  fullscreen: rawParams.fullscreen !== 'false',
  editable: rawParams.editable !== 'false',
  theme,
}
