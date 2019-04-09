#!/bin/bash

cd studio

# Path to swiftlint when in the studio
SWIFT_LINT=./Pods/SwiftLint/swiftlint

if [[ -e "${SWIFT_LINT}" ]]; then
    count=0
    for file_path in $@; do
        export SCRIPT_INPUT_FILE_$count="$file_path"
        count=$((count + 1))
    done

    ##### Make the count avilable as global variable #####
    export SCRIPT_INPUT_FILE_COUNT=$count

    echo "${SCRIPT_INPUT_FILE_COUNT}"

    ##### Lint files or exit if no files found for lintint #####
    if [ "$count" -ne 0 ]; then
        echo "Found lintable files! Linting..."
        $SWIFT_LINT lint --use-script-input-files --config .swiftlint.yml
    else
        echo "No files to lint!"
        exit 0
    fi

    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        :
    else
        echo ""
        echo "Violation found of the type ERROR! Must fix before commit!"
    fi
    exit $RESULT

else
    echo "warning: SwiftLint not installed, please run `cd studio && bundle && bundle exec pod install`"
fi
