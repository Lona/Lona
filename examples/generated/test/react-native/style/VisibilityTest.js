// Compiled by Lona Version 0.5.2

import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class VisibilityTest extends React.Component {
  render() {


    let Title$visible

    Title$visible = this.props.enabled
    return (
      <View style={styles.container}>
        {false && <View style={styles.inner} />}
        {Title$visible && <Text style={styles.title}> {"Enabled"} </Text>}
        <View style={styles.view} />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  container: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.green300,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100
  },
  title: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  view: {
    alignItems: "flex-start",
    backgroundColor: colors.blue300,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100
  }
})