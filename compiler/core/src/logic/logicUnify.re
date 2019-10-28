open Monad;

/* Types */

type functionArgument = {
  label: option(string),
  type_: t,
}
and t =
  | Evar(string)
  | Cons(string, list(t))
  | Gen(string)
  | Fun(list(functionArgument), t);

type unificationError =
  | NameMismatch(t, t)
  | GenericArgumentsCountMismatch(t, t)
  | GenericArgumentsLabelMismatch(
      list(functionArgument),
      list(functionArgument),
    )
  | KindMismatch(t, t);

type substitution = Jet.dictionary(t, t);

type constraint_ = {
  head: t,
  tail: t,
};

let rec functionArgumentDescription = x =>
  switch (x.label) {
  | Some(label) => label ++ ": " ++ typeDescription(x.type_)
  | None => typeDescription(x.type_)
  }
and typeDescription = x =>
  switch (x) {
  | Evar(string) => string
  | Cons(name, parameters) =>
    if (parameters == []) {
      name;
    } else {
      let parametersDescription =
        parameters |> List.map(typeDescription) |> Format.joinWith(", ");
      {j|$name<$parametersDescription>|j};
    }
  | Fun(arguments, returnType) =>
    let argumentsDescription =
      arguments
      |> List.map(functionArgumentDescription)
      |> Format.joinWith(", ");
    let returnTypeDescription = typeDescription(returnType);
    {j|($argumentsDescription) -> $returnTypeDescription|j};
  | Gen(string) => string
  }
and substitutionDescription = substitution =>
  substitution#customDescription(
    ~describeKey=typeDescription,
    ~describeValue=typeDescription,
  );

exception UnificationError(unificationError);

/* Functions */

let rec substitute = (substitution: substitution, type_: t): t => {
  let rec resolveType = type_ =>
    switch (substitution#get(type_)) {
    | None => type_
    | Some(next) => resolveType(next)
    };

  let resolvedType = resolveType(type_);

  switch (resolvedType) {
  | Evar(_)
  | Gen(_) => resolvedType
  | Cons(name, parameters) =>
    Cons(name, parameters |> List.map(substitute(substitution)))
  | Fun(arguments, returnType) =>
    Fun(
      arguments
      |> List.map(arg =>
           {label: arg.label, type_: substitute(substitution, arg.type_)}
         ),
      substitute(substitution, returnType),
    )
  };
};

let rec genericNames = (type_: t): list(string) =>
  switch (type_) {
  | Evar(_) => []
  | Cons(_, parameters) =>
    parameters |> List.map(genericNames) |> List.concat
  | Gen(name) => [name]
  | Fun(arguments, returnType) =>
    let argumentTypes = arguments |> List.map(arg => arg.type_);
    argumentTypes @ [returnType] |> List.map(genericNames) |> List.concat;
  };

let replaceGenericsWithEvars = (getName: unit => string, type_: t): t => {
  let substitution: Jet.dictionary(t, t) = new Jet.dictionary;
  genericNames(type_)
  |> List.iter(name => {
       substitution#set(Gen(name), Evar(getName()));
       ();
     });
  substitute(substitution, type_);
};

let unify =
    (
      ~constraints: list(constraint_),
      ~substitution: substitution=new Jet.dictionary,
      (),
    )
    : substitution => {
  let constraints = ref(constraints);

  while (constraints^ != []) {
    let constraint_ = List.hd(constraints^);
    constraints := List.tl(constraints^);

    let {head, tail} = constraint_;

    if (head != tail) {
      switch (head, tail) {
      | (
          Fun(headArguments, headReturnType),
          Fun(tailArguments, tailReturnType),
        ) =>
        let headContainsLabels =
          headArguments |> List.exists(arg => arg.label != None);
        let tailContainsLabels =
          tailArguments |> List.exists(arg => arg.label != None);

        if (headContainsLabels
            && !tailContainsLabels
            && tailArguments != []
            || tailContainsLabels
            && !headContainsLabels
            && headArguments != []) {
          raise(
            UnificationError(
              GenericArgumentsLabelMismatch(headArguments, tailArguments),
            ),
          );
        };

        if (!headContainsLabels && !tailContainsLabels) {
          if (List.length(headArguments) != List.length(tailArguments)) {
            raise(
              UnificationError(GenericArgumentsCountMismatch(head, tail)),
            );
          };

          List.iter2(
            (a, b) =>
              constraints := constraints^ @ [{head: a.type_, tail: b.type_}],
            headArguments,
            tailArguments,
          );
        } else {
          let headLabels =
            headArguments |> List.map(arg => arg.label) |> Sequence.compact;
          let tailLabels =
            tailArguments |> List.map(arg => arg.label) |> Sequence.compact;

          /* TODO: Check that this function works */
          let common = Sequence.intersectMem(headLabels, tailLabels);

          common
          |> List.iter(label => {
               let headArgumentType =
                 (
                   headArguments
                   |> Sequence.firstWhere(arg => arg.label == Some(label))
                   |> getExn
                 ).
                   type_;
               ();
               let tailArgumentType =
                 (
                   tailArguments
                   |> Sequence.firstWhere(arg => arg.label == Some(label))
                   |> getExn
                 ).
                   type_;
               constraints :=
                 constraints^
                 @ [{head: headArgumentType, tail: tailArgumentType}];
             });
        };

        constraints :=
          constraints^ @ [{head: headReturnType, tail: tailReturnType}];
      | (Cons(headName, headParameters), Cons(tailName, tailParameters)) =>
        if (headName != tailName) {
          raise(UnificationError(NameMismatch(head, tail)));
        };

        if (List.length(headParameters) != List.length(tailParameters)) {
          raise(
            UnificationError(GenericArgumentsCountMismatch(head, tail)),
          );
        };

        List.iter2(
          (a, b) => constraints := constraints^ @ [{head: a, tail: b}],
          headParameters,
          tailParameters,
        );
      | (Gen(_), _)
      | (_, Gen(_)) =>
        Js.log3("tried to unify generics (problem?)", head, tail)
      | (Evar(_), _) => substitution#set(head, tail)
      | (_, Evar(_)) => substitution#set(tail, head)
      | (Cons(_, _), Fun(_, _))
      | (Fun(_, _), Cons(_, _)) =>
        raise(UnificationError(KindMismatch(head, tail)))
      };

      constraints :=
        constraints^
        |> List.map(constraint_ =>
             switch (
               substitution#get(constraint_.head),
               substitution#get(constraint_.tail),
             ) {
             | (Some(updatedHead), Some(updatedTail)) => {
                 head: updatedHead,
                 tail: updatedTail,
               }
             | (Some(updatedHead), None) => {
                 head: updatedHead,
                 tail: constraint_.tail,
               }
             | (None, Some(updatedTail)) => {
                 head: constraint_.head,
                 tail: updatedTail,
               }
             | (None, None) => constraint_
             }
           );
    };
  };

  substitution;
};

/* Builtins */

let unit: t = Cons("Void", []);
let bool: t = Cons("Boolean", []);
let number: t = Cons("Number", []);
let string: t = Cons("String", []);
let color: t = Cons("Color", []);
let shadow: t = Cons("Shadow", []);
let textStyle: t = Cons("TextStyle", []);
let optional = (type_: t): t => Cons("Optional", [type_]);
let array = (type_: t): t => Cons("Array", [type_]);