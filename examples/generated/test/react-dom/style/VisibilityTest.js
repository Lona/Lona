import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class VisibilityTest extends React.Component {
  render() {

    let Title$visible

    Title$visible = this.props.enabled
    return (
      <div style={Object.assign({}, styles.container, {})}>
        {false && <div style={Object.assign({}, styles.inner, {})} />}
        {
          Title$visible &&
          <span style={Object.assign({}, styles.title, {})}>
            {"Enabled"}
          </span>
        }
        <div style={Object.assign({}, styles.view, {})} />
      </div>
    );
  }
};

let styles = {
  container: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.green300,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  },
  title: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: "0 0 auto",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  view: {
    alignItems: "flex-start",
    backgroundColor: colors.blue300,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "100px",
    height: "100px"
  }
}