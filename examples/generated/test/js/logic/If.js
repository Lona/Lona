import { View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class If extends React.Component {
  render() {
    let View$backgroundColor;
    if (this.props.enabled) {
      View$backgroundColor = "red500"
    }
    return (
      <View style={[ styles.View, {} ]} backgroundColor={View$backgroundColor}>

      </View>
    );
  }
};

let styles = StyleSheet.create({ View: { alignSelf: "stretch" } });