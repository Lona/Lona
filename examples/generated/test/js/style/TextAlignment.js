class TextAlignment extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <View style={[ styles.View 1, {} ]}>
          <View style={[ styles.View 2, {} ]} backgroundColor={"#D8D8D8"}>

          </View>
          <Image
            style={[ styles.Image, {} ]}
            image={"file://./assets/icon_128x128.png"}
          >

          </Image>
          <Text style={[ styles.Text, {} ]} text={"Welcome to Lona Studio"}>

          </Text>
          <Text style={[ styles.Text 1, {} ]} text={"Version 1.0.2"}>

          </Text>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch" },
  View 1: {
    alignItems: "center",
    alignSelf: "stretch",
    height: 400,
    justifyContent: "center"
  },
  View 2: {},
  Image: { height: 100, width: 100 },
  Text: { font: "display1", marginTop: 16 },
  Text 1: { font: "subheading2", marginTop: 16 }
});