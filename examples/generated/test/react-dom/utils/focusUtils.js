export const isFocused = componentOrDomNode => {
  if (componentOrDomNode.isReactComponent) {
    return componentOrDomNode.isFocused();
  }

  return componentOrDomNode === document.activeElement;
};
