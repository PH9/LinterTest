# Run SwiftLint
# Inspired from https://gist.github.com/PH9/52e2e43b93dc2d860b569ccf31f49c6e
set -e

START_DATE=$(date +"%s")

SWIFT_LINT=/usr/local/bin/swiftlint

if [[ -e "${SWIFT_LINT}" ]]; then
    echo "[I] Found SwiftLint at ${SWIFT_LINT}"
else
    echo "[!] Local SwiftLint not found at ${SWIFT_LINT}"
    SWIFT_LINT=${PWD}/Pods/SwiftLint/swiftlint
    echo "[I] Try to using SwiftLint from cocoapods at ${SWIFT_LINT}"
fi

if [[ -e "${SWIFT_LINT}" ]]; then
    echo "[I] SwiftLint version: $(${SWIFT_LINT} version)"

    # Run for both staged and unstaged files
    SWIFT_GIT_DIFF="$(git diff --name-only | grep '\.swift' | tr '\n' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    SWIFT_CACHED_DIFF="$(git diff --cached --name-only | grep '\.swift' | tr '\n' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    ALL_SWIFT_DIFF="$(echo "${SWIFT_GIT_DIFF} ${SWIFT_CACHED_DIFF}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    echo ${ALL_SWIFT_DIFF}

    if [[ $ALL_SWIFT_DIFF != "" ]]; then
        ${SWIFT_LINT} autocorrect --format "${ALL_SWIFT_DIFF}"
        ${SWIFT_LINT} lint "${ALL_SWIFT_DIFF}"
    fi
else
    echo "[!] SwifLint is not installed."
    echo "[!] Expected location is '${SWIFT_LINT}'"
    echo "[!] Please install it. eg. 'brew install swiftlint'"
    echo "[!] Or using via Cocoapods by oyt 'pod 'SwiftLint' in your Podfile"
    exit 1
fi

END_DATE=$(date +"%s")

DIFF=$(($END_DATE - $START_DATE))
echo "SwiftLint took $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds to complete."
