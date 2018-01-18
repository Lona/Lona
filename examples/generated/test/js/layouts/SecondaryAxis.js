class SecondaryAxis extends React.Component {
  render() {
    return (
      <View style={[ styles.Container, {} ]}>
        <View style={[ styles.Fixed, {} ]} backgroundColor={"#D8D8D8"}>

        </View>
        <View style={[ styles.Fit, {} ]} backgroundColor={"#D8D8D8"}>
          <Text style={[ styles.Text, {} ]} text={"Text goes here"}>

          </Text>
        </View>
        <View style={[ styles.Fill, {} ]} backgroundColor={"#D8D8D8"}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  Container: {
    alignSelf: "stretch",
    flex: 0,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 42,
    paddingTop: 24
  },
  Fixed: { height: 100, marginBottom: 24, width: 100 },
  Fit: {
    height: 100,
    marginBottom: 24,
    paddingBottom: 12,
    paddingLeft: 12,
    paddingRight: 12,
    paddingTop: 12
  },
  Text: {},
  Fill: { alignSelf: "stretch", height: 100 }
});