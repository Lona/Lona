import React from "react"
import { Image, View, StyleSheet } from "react-native"

import colors from "../colors"
import textStyles from "../textStyles"

export default class LocalAsset extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Image
          style={[ styles.image, {} ]}
          source={require("../assets/icon_128x128.png")}

        />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignItems: "flex-start", alignSelf: "stretch", flex: 0 },
  image: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    width: 100,
    height: 100
  }
})