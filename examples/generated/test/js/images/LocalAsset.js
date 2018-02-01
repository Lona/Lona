class LocalAsset extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <Image
          style={[ styles.Image, {} ]}
          backgroundColor={"#D8D8D8"}
          image={"file://./assets/icon_128x128.png"}
        >

        </Image>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch", flex: 0 },
  Image: { height: 100, width: 100 }
});