import Danger

let danger = Danger()

// Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if danger.github.pullRequest.title.contains("[WIP]") {
    warn("PR is classed as Work in Progress")
}

// Warn when there is a big PR
if danger.github.pullRequest.additions ?? 0 > 500 {
    warn("Big PR, try to keep changes smaller if you can")
}

// Mainly to encourage writing up some reasoning about the PR, rather than
// just leaving a title
if let body = danger.github.pullRequest.body, body.count < 5 {
    fail("Please provide a summary in the Pull Request description")
}

// If these are all empty something has gone wrong, better to raise it in a comment
if danger.git.modifiedFiles.isEmpty && danger.git.createdFiles.isEmpty && danger.git.deletedFiles.isEmpty {
    fail("This PR has no changes at all, this is likely an issue during development.")
}

// Warn when library files has been updated but not tests.
let has_app_changes = !danger.git.modifiedFiles.filter({file in
    return file.contains("Sources")
}).isEmpty
let tests_updated = !danger.git.modifiedFiles.filter({file in
    return file.contains("Tests")
}).isEmpty
if has_app_changes && !tests_updated {
    warn("The library files were changed, but the tests remained unmodified. Consider updating or adding to the tests to match the library changes.")
}

// Run SwiftLint
SwiftLint.lint(inline: true, directory: "studio", configFile: ".swiftlint.yml", lintAllFiles: true, swiftlintPath: "./studio/Pods/SwiftLint/swiftlint")
