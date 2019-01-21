import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

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
      <View style={styles.container}>
        <View style={[styles.inner, { ...Inner$shadow }]} />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  container: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: 20,
    paddingBottom: 20
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.blue300,
    flexDirection: "column",
    justifyContent: "flex-start",
    ...Shadows.get("elevation2"),
    width: 60,
    height: 60
  }
})