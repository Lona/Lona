[@bs.val] [@bs.scope "console"] external warn: 'a => unit = "error";
[@bs.val] [@bs.scope "console"] external warn2: ('a, 'b) => unit = "error";
[@bs.val] [@bs.scope "console"] external warn3: ('a, 'b, 'c) => unit = "error";
[@bs.val] [@bs.scope "console"]
external warn4: ('a, 'b, 'c, 'd) => unit = "error";