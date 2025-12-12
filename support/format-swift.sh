#!/bin/bash

# Format Swift files using swift-format
# This script formats all Swift files in the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${YELLOW}Formatting Swift files in: $PROJECT_ROOT${NC}"

# Find swift-format in Xcode's toolchain
# Try the actual Xcode app first, then fall back to command line tools
if [ -f "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format" ]; then
    SWIFT_FORMAT="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
else
    XCODE_PATH=$(xcode-select -p)
    SWIFT_FORMAT="${XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
fi

# Check if swift-format exists
if [ ! -f "$SWIFT_FORMAT" ]; then
    echo -e "${RED}Error: swift-format not found in Xcode toolchain${NC}"
    echo "Expected locations:"
    echo "  /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
    echo "  ${XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-format"
    echo ""
    echo "Make sure Xcode 16.0+ is installed"
    exit 1
fi

# Find all Swift files in the project (excluding .build and vendor directories)
find "$PROJECT_ROOT" \
    -name "*.swift" \
    -not -path "*/\.build/*" \
    -not -path "*/vendor/*" \
    -not -path "*/Pods/*" \
    -not -path "*/DerivedData/*" \
    -not -path "*/.swiftpm/*" \
    -print0 | while IFS= read -r -d '' file; do
    
    # Get relative path for cleaner output
    relative_path="${file#$PROJECT_ROOT/}"
    
    # Format the file in place
    if "$SWIFT_FORMAT" format --configuration "$PROJECT_ROOT/.swift-format" --in-place "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Formatted: $relative_path"
    else
        echo -e "${RED}✗${NC} Failed to format: $relative_path"
    fi
done

echo -e "${GREEN}Swift formatting complete!${NC}"