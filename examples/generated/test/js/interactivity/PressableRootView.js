class PressableRootView extends React.Component {
  render() {
    let Inner$onPress;
    let Inner$backgroundColor;
    let Button$onPress;
    Button$onPress = this.props.onPressButton
    Inner$onPress = this.props.onPressInner
    if (Inner$hovered) {
      Inner$backgroundColor = "blue300"
    }
    return (
      <View style={[ styles.Button, { onPress: Button$onPress } ]}>
        <View
          style={[ styles.Inner, { onPress: Inner$onPress } ]}
          backgroundColor={Inner$backgroundColor}
        >

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  Button: {
    alignSelf: "stretch",
    flex: 0,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  Inner: { height: 100, width: 100 }
});