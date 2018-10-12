import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class Optionals extends React.Component {
  render() {

    let Label$text
    let View$backgroundColor
    Label$text = ""
    View$backgroundColor = "transparent"

    if (this.props.boolParam == true) {
      Label$text = "boolParam is true"
      View$backgroundColor = colors.green200
    }
    if (this.props.boolParam == false) {
      Label$text = "boolParam is false"
      View$backgroundColor = colors.red200
    }
    if (this.props.boolParam == null) {
      Label$text = "boolParam is null"
    }
    return (
      <View style={[ styles.view, { backgroundColor: View$backgroundColor } ]}>
        <Text style={[ styles.label, {} ]}>
          {Label$text}
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
  label: {
    ...textStyles.body1,
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})