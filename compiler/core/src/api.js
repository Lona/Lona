module.exports = {
  core: {
    color: require("./core/color.bs"),
    decode: require("./core/decode.bs"),
    layer: require("./core/layer.bs"),
    logic: require("./core/logic.bs"),
    lonaValue: require("./core/lonaValue.bs"),
    options: require("./core/options.bs"),
    render: require("./core/render.bs"),
    textStyle: require("./core/textStyle.bs"),
    types: require("./core/types.bs")
  },
  swift: {
    options: require("./swift/swiftOptions.bs"),
    format: require("./swift/swiftFormat.bs"),
    ast: require("./swift/swiftAst.bs"),
    logic: require("./swift/swiftLogic.bs"),
    document: require("./swift/swiftDocument.bs"),
    render: require("./swift/swiftRender.bs"),
    color: require("./swift/swiftColor.bs"),
    textStyle: require("./swift/swiftTextStyle.bs"),
    component: require("./swift/swiftComponent.bs")
  },
  js: {
    ast: require("./javaScript/javaScriptAst.bs"),
    render: require("./javaScript/javaScriptRender.bs"),
    logic: require("./javaScript/javaScriptLogic.bs"),
    color: require("./javaScript/javaScriptColor.bs"),
    component: require("./javaScript/javaScriptComponent.bs")
  },
  xml: {
    ast: require("./xml/xmlAst.bs"),
    render: require("./xml/xmlRender.bs"),
    color: require("./xml/xmlColor.bs")
  },
  reason: {
    list: require("bs-platform/lib/js/array.js").to_list
  }
};
