class PressableRootView extends React.Component {
  render() {
    let View$onPress;
    View$onPress = this.props.onPress
    return (
      <View style={[ styles.View, { onPress: View$onPress } ]}>
        <View style={[ styles.View 1, {} ]} backgroundColor={"#D8D8D8"}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch", flex: 0 },
  View 1: { height: 100, width: 100 }
});