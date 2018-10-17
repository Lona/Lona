import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class ShadowsTest extends React.Component {
  render() {

    let Inner$shadow
    Inner$shadow = shadows.elevation2

    if (this.props.largeShadow) {
      Inner$shadow = shadows.elevation3
    }
    return (
      <div style={styles.container}>
        <div style={Object.assign({}, styles.inner, { ...Inner$shadow })} />
      </div>
    );
  }
};

let styles = {
  container: {
    alignItems: "center",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: "20px",
    paddingBottom: "20px"
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.blue300,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    ...shadows.elevation2,
    width: "60px",
    height: "60px"
  }
}