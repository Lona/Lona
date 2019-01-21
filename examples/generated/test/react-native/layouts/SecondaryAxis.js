import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {



    return (
      <View style={styles.container}>
        <View style={styles.fixed} />
        <View style={styles.fit}>
          <Text style={styles.text}>
            {"Text goes here"}
          </Text>
        </View>
        <View style={styles.fill} />
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
    justifyContent: "flex-start",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  fixed: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: 24,
    width: 100,
    height: 100
  },
  fit: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flexDirection: "column",
    justifyContent: "flex-start",
    marginBottom: 24,
    paddingTop: 12,
    paddingRight: 12,
    paddingBottom: 12,
    paddingLeft: 12,
    height: 100
  },
  fill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: "#D8D8D8",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})