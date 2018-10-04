import React from "react"
import { Text, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class Assign extends React.Component {
  render() {

    let Text$text

    Text$text = this.props.text
    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, {} ]}>
          {Text$text}
        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignItems: "flex-start", alignSelf: "stretch", flex: 0 },
  text: { ...textStyles.body1, alignItems: "flex-start", flex: 0 }
})