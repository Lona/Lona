export const isFocused = componentOrDomNode => {
  if (componentOrDomNode.isReactComponent) {
    return componentOrDomNode.isFocused();
  }

  return componentOrDomNode === document.activeElement;
};

export const focusFirst = elements => {
  if (elements[0] && elements[0].focus) {
    elements[0].focus();

    return true;
  }

  return false;
};

export const focusLast = elements => {
  let lastElement = elements[elements.length - 1];

  if (lastElement && lastElement.focusLast) {
    lastElement.focusLast();

    return true;
  } else if (lastElement && lastElement.focus) {
    lastElement.focus();

    return true;
  }

  return false;
};

export const focusNext = elements => {
  let nextIndex = elements.findIndex(isFocused) + 1;

  if (nextIndex >= elements.length) {
    return false;
  }

  if (elements[nextIndex].focus) {
    elements[nextIndex].focus();

    return true;
  }

  return false;
};

export const focusPrevious = elements => {
  let previousIndex = elements.findIndex(isFocused) - 1;

  if (previousIndex < 0) {
    return false;
  }

  if (elements[previousIndex].focusLast) {
    elements[previousIndex].focusLast();

    return true;
  } else if (elements[previousIndex].focus) {
    elements[previousIndex].focus();

    return true;
  }

  return false;
};
