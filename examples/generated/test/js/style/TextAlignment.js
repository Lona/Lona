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
  View: {
    alignSelf: "stretch",
    paddingBottom: 10,
    paddingLeft: 10,
    paddingRight: 10,
    paddingTop: 10
  },
  View 1: {
    alignItems: "center",
    alignSelf: "stretch",
    height: 400,
    justifyContent: "center"
  },
  View 2: {},
  Image: { height: 100, width: 100 },
  Text: {
    alignSelf: "stretch",
    font: "display1",
    marginTop: 16,
    textAlign: "center"
  },
  Text 1: {
    alignSelf: "stretch",
    font: "subheading2",
    marginTop: 16,
    textAlign: "center"
  }
});