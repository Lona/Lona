let findChildPages = (root: MdxTypes.root): list(string) => {
  root.children
  |> List.map((child: MdxTypes.blockNode) =>
       switch (child) {
       | Page({url}) => Some(url)
       | _ => None
       }
     )
  |> Sequence.compact;
};