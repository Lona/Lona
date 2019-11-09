module List = {
  type t('a) = list('a);
  let decode = Json.Decode.list;
  let encode = Json.Encode.list;
};

module Int = {
  type t = int;
  let decode = Json.Decode.int;
  let encode = Json.Encode.int;
};