class dictionary ('k, 'v) = {
  as self;
  val mutable data: list(('k, 'v)) = [];
  pub set = (k: 'k, v: 'v): unit => {
    let rest = data |> List.remove_assoc(k);
    data = [(k, v), ...rest];
  };
  pub get = (k: 'k): option('v) =>
    switch (data |> List.assoc(k)) {
    | value => Some(value)
    | exception Not_found => None
    };
  pub keys = (): list('k) => data |> List.map(((k, _)) => k);
  pub values = (): list('v) => data |> List.map(((_, v)) => v);
  pub pairs = (): list(('k, 'v)) => data;
  pub assign = (other: dictionary('k, 'v)): unit =>
    other#pairs() |> List.iter(((k, v)) => self#set(k, v));
  pub description = (): string => {
    let items = List.map(((k, v)) => {j|$k: $v|j}, self#pairs());
    "{ " ++ (items |> Format.joinWith(", ")) ++ " }";
  };
  pub customDescription =
      (~describeKey: 'k => string, ~describeValue: 'v => string): string => {
    let items =
      List.map(
        ((k, v)) => describeKey(k) ++ ": " ++ describeValue(v),
        self#pairs(),
      );
    "{ " ++ (items |> Format.joinWith(", ")) ++ " }";
  };
};

class scopeStack ('k, 'v) = {
  val mutable scopes: list(dictionary('k, 'v)) = [new dictionary];
  pub get = (k: 'k): option('v) =>
    scopes
    |> List.map(scope => scope#get(k))
    |> Sequence.compact
    |> Sequence.first;
  pub set = (k: 'k, v: 'v): unit => {
    let hd = List.hd(scopes);
    hd#set(k, v);
  };
  pub push = (): unit => scopes = [new dictionary, ...scopes];
  pub pop = (): dictionary('k, 'v) => {
    let [hd, ...rest] = scopes;
    scopes = rest;
    hd;
  };
  pub flattened = (): dictionary('k, 'v) => {
    let result: dictionary('k, 'v) = new dictionary;

    scopes
    |> List.rev
    |> List.map(scope => scope#pairs())
    |> List.concat
    |> List.iter(((k, v)) => result#set(k, v));

    result;
  };
};