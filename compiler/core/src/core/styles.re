type flexLayout('a) = {
  alignItems: 'a,
  alignSelf: 'a,
  display: 'a,
  justifyContent: 'a,
  flex: 'a,
  flexDirection: 'a,
  width: 'a,
  height: 'a,
};

type edgeInsets('a) = {
  top: 'a,
  right: 'a,
  bottom: 'a,
  left: 'a,
};

type layout('a) = {
  flex: flexLayout('a),
  padding: edgeInsets('a),
  margin: edgeInsets('a),
};

type border('a) = {
  borderRadius: 'a,
  borderWidth: 'a,
  borderColor: 'a,
};

type textStyles('a) = {
  textAlign: 'a,
  textStyle: 'a,
};

type viewLayerStyles('a) = {
  layout: layout('a),
  border: border('a),
  backgroundColor: 'a,
  textStyles: textStyles('a),
};

/* type styleValues = styles(Types.lonaValue); */
type namedStyles('a) = {
  name: string,
  styles: viewLayerStyles('a),
};

type styleSets('a) = list(namedStyles('a));

let print = (styleSets: styleSets('a)) =>
  styleSets
  |> List.iter(set => Js.log2(set.name, Js.String.make(set.styles)));

let emptyNamedStyle = (name: string): namedStyles(option('a)) => {
  name,
  styles: {
    layout: {
      flex: {
        alignItems: None,
        alignSelf: None,
        display: None,
        justifyContent: None,
        flex: None,
        flexDirection: None,
        width: None,
        height: None,
      },
      padding: {
        top: None,
        right: None,
        bottom: None,
        left: None,
      },
      margin: {
        top: None,
        right: None,
        bottom: None,
        left: None,
      },
    },
    border: {
      borderRadius: None,
      borderWidth: None,
      borderColor: None,
    },
    backgroundColor: None,
    textStyles: {
      textAlign: None,
      textStyle: None,
    },
  },
};

/* let map = (set: layerStyles('a)): layerStyles('b) => {
     {

     };
   }; */