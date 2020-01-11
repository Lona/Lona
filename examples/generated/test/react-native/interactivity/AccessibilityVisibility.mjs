import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../foundation/colors"
import shadows from "../foundation/shadows"
import textStyles from "../foundation/textStyles"

export default class AccessibilityVisibility extends React.Component {
  render() {


    let Text$visible

    Text$visible = this.props.showText
    return (
      <View style={styles.view}>
        <View
          style={styles.greyBox}
          accessibilityLabel={"Grey box"}
          accessible={true}

        />
        {
          Text$visible &&
          <Text
            style={styles.text}
            accessibilityLabel={"Some text that is sometimes hidden"}
            accessible={true}
          >
            {"Sometimes hidden"}
          </Text>
        }
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
  greyBox: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 40
  },
  text: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})