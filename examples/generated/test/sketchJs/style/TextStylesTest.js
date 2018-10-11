import React from "react"
import { Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class TextStylesTest extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text1, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text2, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text3, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text4, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text5, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text6, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text7, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text8, {} ]}>
          {"Text goes here"}
        </Text>
        <Text style={[ styles.text9, {} ]}>
          {"Text goes here"}
        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text: {
    ...TextStyles.get("display4"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text1: {
    ...TextStyles.get("display3"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text2: {
    ...TextStyles.get("display2"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text3: {
    ...TextStyles.get("display1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text4: {
    ...TextStyles.get("headline"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text5: {
    ...TextStyles.get("subheading2"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text6: {
    ...TextStyles.get("subheading1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text7: {
    ...TextStyles.get("body2"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text8: {
    ...TextStyles.get("body1"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  text9: {
    ...TextStyles.get("caption"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})