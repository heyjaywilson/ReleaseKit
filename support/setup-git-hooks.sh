#!/bin/bash

# Setup git pre-commit hook for Swift formatting

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

cat > "$PROJECT_ROOT/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

if ! git diff --cached --name-only --diff-filter=ACMR | grep -q '\.swift$'; then
    exit 0
fi

if [ -f "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format" ]; then
    SWIFT_FORMAT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
else
    XCODE_PATH=$(xcode-select -p)
    SWIFT_FORMAT="${XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
fi

if [ ! -f "$SWIFT_FORMAT" ]; then
    echo "Error: swift-format not found"
    exit 1
fi

git diff --cached --name-only --diff-filter=ACMR | grep '\.swift$' | while IFS= read -r file; do
    if [ -f "$file" ]; then
        "$SWIFT_FORMAT" format --configuration "$PROJECT_ROOT/.swift-format" --in-place "$PROJECT_ROOT/$file" 2>/dev/null
        git add "$file"
    fi
done

exit 0
EOF

chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"

echo "Git pre-commit hook setup complete"