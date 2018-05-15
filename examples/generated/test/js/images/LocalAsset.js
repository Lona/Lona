import { Image, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

export default class LocalAsset extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <Image
          style={[ styles.image, {} ]}
          image={"file://./assets/icon_128x128.png"}
        >

        </Image>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  image: { backgroundColor: "#D8D8D8", height: 100, width: 100 }
});