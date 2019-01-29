import React, { Component } from "react";
import "./App.css";

import AccessibilityTest from "./generated/interactivity/AccessibilityTest";
import AccessibilityVisibility from "./generated/interactivity/AccessibilityVisibility";
import AccessibilityNested from "./generated/interactivity/AccessibilityNested";

class App extends Component {
  state = {
    checked: false
  };

  accessibilityNested = React.createRef();
  accessibilityTest = React.createRef();
  accessibilityVisibility = React.createRef();

  render() {
    return (
      <div className="App">
        <div
          tabIndex={0}
          style={styles.focusTrap}
          onKeyDown={e => {
            if (e.key === "Tab" && !e.shiftKey) {
              this.accessibilityNested.current.focus();

              e.stopPropagation();
              e.preventDefault();
            }
          }}
        />
        <AccessibilityNested
          ref={this.accessibilityNested}
          onFocusNext={() => this.accessibilityTest.current.focus()}
          isChecked={this.state.checked}
          onChangeChecked={() =>
            this.setState({ checked: !this.state.checked })
          }
        />
        <AccessibilityTest
          ref={this.accessibilityTest}
          onFocusNext={() => this.accessibilityVisibility.current.focus()}
          onFocusPrevious={() => this.accessibilityNested.current.focusLast()}
          checkboxValue={this.state.checked}
          onToggleCheckbox={() =>
            this.setState({ checked: !this.state.checked })
          }
        />
        <AccessibilityVisibility
          ref={this.accessibilityVisibility}
          onFocusPrevious={() => this.accessibilityTest.current.focusLast()}
          showText={this.state.checked}
        />
        <div
          tabIndex={0}
          style={styles.focusTrap}
          onKeyDown={e => {
            if (e.key === "Tab" && e.shiftKey) {
              this.accessibilityVisibility.current.focusLast();

              e.stopPropagation();
              e.preventDefault();
            }
          }}
        />
      </div>
    );
  }
}

export default App;

const styles = {
  focusTrap: {
    height: 10,
    background: "green"
  }
};
