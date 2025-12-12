#!/bin/bash

# Format only changed Swift files using swift-format
# This script formats only staged and modified Swift files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${YELLOW}Formatting changed Swift files in: $PROJECT_ROOT${NC}"

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

# Get list of changed Swift files (staged and modified)
# Include both staged files and modified files
CHANGED_FILES=$(git diff --name-only --diff-filter=ACM HEAD -- '*.swift' && git diff --name-only --diff-filter=ACM --cached -- '*.swift' | sort -u)

if [ -z "$CHANGED_FILES" ]; then
    echo -e "${GREEN}No changed Swift files to format${NC}"
    exit 0
fi

# Count total files
TOTAL_FILES=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
FORMATTED_COUNT=0
FAILED_COUNT=0

echo -e "${YELLOW}Found $TOTAL_FILES changed Swift file(s)${NC}"
echo ""

# Format each changed file
while IFS= read -r relative_path; do
    # Skip empty lines
    [ -z "$relative_path" ] && continue
    
    # Get full path
    file="$PROJECT_ROOT/$relative_path"
    
    # Check if file exists (might have been deleted)
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠${NC} Skipped (file not found): $relative_path"
        continue
    fi
    
    # Format the file in place
    if "$SWIFT_FORMAT" format --configuration "$PROJECT_ROOT/.swift-format" --in-place "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Formatted: $relative_path"
        ((FORMATTED_COUNT++))
        
        # If file was already staged, re-stage it after formatting
        if git diff --cached --name-only | grep -q "^$relative_path$"; then
            git add "$file"
        fi
    else
        echo -e "${RED}✗${NC} Failed to format: $relative_path"
        ((FAILED_COUNT++))
    fi
done <<< "$CHANGED_FILES"

echo ""
echo -e "${GREEN}Swift formatting complete!${NC}"
echo -e "Formatted: $FORMATTED_COUNT file(s)"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_COUNT file(s)${NC}"
fi