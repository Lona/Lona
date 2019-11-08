type t = {ignore: list(string)};

let parseFile = content => {
  let json = content |> Js.Json.parseExn;
  Json.Decode.{
    ignore:
      switch (json |> optional(field("ignore", list(string)))) {
      | Some(files) => files
      | None => ["node_modules", ".git"]
      },
  };
};