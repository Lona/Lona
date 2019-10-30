let create =
    (value: LogicEvaluate.Value.t): option(TokenTypes.tokenValue) =>
  switch (value.type_, value.memory) {
  | (type_, Record(fields)) when type_ == LogicUnify.color =>
    let value = fields#get("value");
    switch (value) {
    | Some(Some({memory: String(css)})) => Some(Color({css: css}))
    | _ => None
    };
  | _ => None
  };