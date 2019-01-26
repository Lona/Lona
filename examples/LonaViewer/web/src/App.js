import React, { Component } from "react";
import "./App.css";

import AccessibilityTest from "./generated/interactivity/AccessibilityTest";
import AccessibilityVisibility from "./generated/interactivity/AccessibilityVisibility";
import AccessibilityNested from "./generated/interactivity/AccessibilityNested";

class App extends Component {
  state = {
    checked: false
  };

  handleKeyDown = event => {
    if (event.key === "Tab" && document.activeElement === document.body) {
      this.accessibilityNested.current.focus();

      event.stopPropagation();
      event.preventDefault();
    }
  };

  componentDidMount() {
    document.addEventListener("keydown", this.handleKeyDown);
  }

  componentWillUnmount() {
    document.removeEventListener("keydown", this.handleKeyDown);
  }

  accessibilityNested = React.createRef();
  accessibilityTest = React.createRef();
  accessibilityVisibility = React.createRef();

  render() {
    return (
      <div className="App">
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
      </div>
    );
  }
}

export default App;
