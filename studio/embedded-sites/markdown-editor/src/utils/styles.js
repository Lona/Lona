/* globals document */
export const appendCSS = css => {
  const element = document.createElement('style')
  element.type = 'text/css'

  if (element.styleSheet) {
    element.styleSheet.cssText = css
  } else {
    element.appendChild(document.createTextNode(css))
  }

  document.head.appendChild(element)
}
