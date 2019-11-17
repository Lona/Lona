open Jest;

let commonArgs = ["node", "bin.js"];

describe("Command parsing", () =>
  test("flatten", () =>
    switch (
      commonArgs
      @ ["flatten", "--workspace", "workspacePath"]
      |> CommandLine.Arguments.scan
    ) {
    | {command: Flatten("workspacePath")} => pass
    | _ => fail("Incorrect command")
    | exception (CommandLine.Command.Unknown(message)) => fail(message)
    }
  )
);