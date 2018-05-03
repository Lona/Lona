import ThemedStyleSheet from 'react-with-styles/lib/ThemedStyleSheet';
import aphroditeInterface from 'react-with-styles-interface-amp-aphrodite';
import { css, withStyles } from 'react-with-styles';

ThemedStyleSheet.registerTheme({});
ThemedStyleSheet.registerInterface(aphroditeInterface);

export { css, withStyles, ThemedStyleSheet };
