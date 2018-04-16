class NestedButtons extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <Button style={[ styles.Button, {} ]} text={"Button 1"}>

        </Button>
        <View style={[ styles.View 1, {} ]}>

        </View>
        <Button style={[ styles.Button2, {} ]} text={"Button 2"}>

        </Button>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    alignSelf: "stretch",
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  Button: {},
  View 1: { alignSelf: "stretch", height: 8 },
  Button2: {}
});