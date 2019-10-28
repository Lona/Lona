/* Experimental class-based library */

module Dictionary = {
  class t ('k, 'v) = {
    as self;
    val mutable data: list(('k, 'v)) = [];
    pub set = (k: 'k, v: 'v): unit => {
      let rest = data |> List.remove_assoc(k);
      data = [(k, v), ...rest];
    };
    pub setting = (k: 'k, v: 'v) => {
      let rest = data |> List.remove_assoc(k);
      {<data: [(k, v), ...rest]>};
    };
    pub get = (k: 'k): option('v) =>
      switch (data |> List.assoc(k)) {
      | value => Some(value)
      | exception Not_found => None
      };
    pub getExn = (k: 'k): 'v => data |> List.assoc(k);
    pub keys = (): list('k) => data |> List.map(((k, _)) => k);
    pub values = (): list('v) => data |> List.map(((_, v)) => v);
    pub pairs = (): list(('k, 'v)) => data;
    pub assign = (other: t('k, 'v)): unit =>
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

  let init = (pairs: list(('k, 'v))): t('k, 'v) => {
    let dictionary = new t;
    pairs |> List.iter(((k, v)) => dictionary#set(k, v));
    dictionary;
  };
};

class scopeStack ('k, 'v) = {
  val mutable scopes: list(Dictionary.t('k, 'v)) = [new Dictionary.t];
  pub get = (k: 'k): option('v) =>
    scopes
    |> List.map(scope => scope#get(k))
    |> Sequence.compact
    |> Sequence.first;
  pub set = (k: 'k, v: 'v): unit => {
    let hd = List.hd(scopes);
    hd#set(k, v);
  };
  pub push = (): unit => scopes = [new Dictionary.t, ...scopes];
  pub pop = (): Dictionary.t('k, 'v) => {
    let [hd, ...rest] = scopes;
    scopes = rest;
    hd;
  };
  pub flattened = (): Dictionary.t('k, 'v) => {
    let result: Dictionary.t('k, 'v) = new Dictionary.t;

    scopes
    |> List.rev
    |> List.map(scope => scope#pairs())
    |> List.concat
    |> List.iter(((k, v)) => result#set(k, v));

    result;
  };
};

module Range = {
  class t (start: int, finish: int) = {
    as _;
    /* Members */
    val start = start;
    val finish = finish;
    pub start = start;
    pub finish = finish;
    /* Mutators */
    pub clamped = (min, max) => {
      let newStart = start < min ? min : start;
      let newFinish = finish > max ? max : finish;
      {<start: newStart, finish: newFinish>};
    };
    pub copy = {<>};
    /* Accessors */
    pub list = {
      let rec range = (start: int, finish: int) =>
        if (start < finish) {
          [start, ...range(start + 1, finish)];
        } else {
          [];
        };
      range(start, finish);
    };
  };

  let empty = (new t)(0, 0);

  let clampWithin = (range: t, value: int) => {
    let value = value < range#start ? range#start : value;
    let value = value > range#finish ? range#finish : value;
    value;
  };
};

module Array = {
  class t ('element) (list) = {
    as self;
    /* Private */
    val elements: list('element) = list;
    pub list = elements;
    /* Iterators */
    pub map = f => {<elements: List.map(f, elements)>};
    pub iter = f => List.iter(f, elements);
    /* Mutators */
    pub append = element => {<elements: elements @ [element]>};
    pub appendElements = newElements => {<elements: elements @ newElements>};
    pub appendArray = (newArray: t('element)) => {<elements:
                                                       elements @ newArray#list>};
    pub insertArray = (i: int, newArray: t('element)) => {
      let prefix = self#prefix(i);
      let suffix = self#suffix(self#count - i);
      {<elements: prefix#list @ newArray#list @ suffix#list>};
    };
    pub insertElements = (i: int, newElements: list('element)) =>
      self#insertArray(i, (new t)(newElements));
    pub insert = (i: int, newElement: 'element) =>
      self#insertElements(i, [newElement]);
    pub copy = {<>};
    /* Accessors */
    pub subrange = (range: Range.t) => {
      let clampedRange = range#clamped(0, self#count);
      let result = clampedRange#list |> List.map(i => List.nth(elements, i));
      {<elements: result>};
    };
    pub prefix = (n: int) => {
      let range = (new Range.t)(0, n)#clamped(0, self#count);
      self#subrange(range);
    };
    pub suffix = (n: int) => {
      let range =
        (new Range.t)(self#count - n, self#count)#clamped(0, self#count);
      self#subrange(range);
    };
    pub get = (i: int) =>
      if (i >= self#count) {
        None;
      } else {
        Some(List.nth(elements, i));
      };
    pub getExn = (i: int) => List.nth(elements, i);
    pub first =
      switch (elements) {
      | [] => None
      | [x, ..._] => Some(x)
      };
    pub last =
      switch (elements) {
      | [] => None
      | _ => Some(List.nth(elements, self#count - 1))
      };
    pub count = List.length(elements);
    pub isEmpty = self#count > 0;
  };
};