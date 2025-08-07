#!/bin/bash

# Parse ZI command line tool output
# Extracts text between "[ZI]" and either end of text or "Optional feedback:" string

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" >&2
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND...]"
    echo ""
    echo "Parse ZI command line tool output to extract text after '[ZI]' marker"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -q, --quiet    Suppress status messages (only output parsed text)"
    echo "  -c, --copy     Copy output to clipboard (requires xclip)"
    echo "  -f, --file     Read from file instead of command output"
    echo "  -r, --raw      Output raw text without any processing"
    echo ""
    echo "Examples:"
    echo "  # Parse output from a command"
    echo "  $0 your-zi-command --args"
    echo ""
    echo "  # Parse from file"
    echo "  $0 --file output.txt"
    echo ""
    echo "  # Parse and copy to clipboard"
    echo "  $0 --copy your-zi-command --args"
    echo ""
    echo "  # Parse from stdin"
    echo "  your-zi-command | $0"
    echo ""
    echo "  # Quiet mode (only output parsed text)"
    echo "  $0 --quiet your-zi-command --args"
}

# Function to parse ZI output
parse_zi_output() {
    local input="$1"
    local quiet="$2"

    # Check if input contains [ZI] marker
    if ! echo "$input" | grep -q "\[ZI\]"; then
        if [ "$quiet" != "true" ]; then
            print_status $RED "Error: No '[ZI]' marker found in input"
        fi
        return 1
    fi

    # Extract everything after [ZI] marker using awk for better multi-line handling
    local zi_content
    zi_content=$(echo "$input" | awk '
        BEGIN { found=0; output="" }
        {
            if (found) {
                if (/^Optional feedback: 👍 \/good or 👎 \/bad/) {
                    exit
                }
                if (output != "") output = output "\n"
                output = output $0
            }
            if (/\[ZI\]/) {
                found=1
                # Extract everything after [ZI] on the same line
                zi_part = $0
                gsub(/.*\[ZI\]/, "", zi_part)
                if (zi_part != "") {
                    output = zi_part
                }
            }
        }
        END { print output }
    ')

    # Clean up leading and trailing whitespace
    zi_content=$(echo "$zi_content" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    if [ -z "$zi_content" ]; then
        if [ "$quiet" != "true" ]; then
            print_status $YELLOW "Warning: No content found after '[ZI]' marker"
        fi
        return 1
    fi

    echo "$zi_content"
    return 0
}

# Parse command line arguments
QUIET=false
COPY_TO_CLIPBOARD=false
READ_FROM_FILE=false
RAW_OUTPUT=false
INPUT_FILE=""
COMMAND_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -c|--copy)
            COPY_TO_CLIPBOARD=true
            shift
            ;;
        -f|--file)
            READ_FROM_FILE=true
            if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                INPUT_FILE="$2"
                shift
            fi
            shift
            ;;
        -r|--raw)
            RAW_OUTPUT=true
            shift
            ;;
        *)
            COMMAND_ARGS+=("$1")
            shift
            ;;
    esac
done

# Check if xclip is available when copy flag is used
if [ "$COPY_TO_CLIPBOARD" = true ] && ! command -v xclip &> /dev/null; then
    print_status $RED "Error: xclip is not installed. Cannot copy to clipboard."
    exit 1
fi

# Get input based on mode
INPUT_TEXT=""

if [ "$READ_FROM_FILE" = true ]; then
    # Read from file
    if [ -z "$INPUT_FILE" ]; then
        if [ ${#COMMAND_ARGS[@]} -gt 0 ]; then
            INPUT_FILE="${COMMAND_ARGS[0]}"
        else
            print_status $RED "Error: No file specified"
            exit 1
        fi
    fi

    if [ ! -f "$INPUT_FILE" ]; then
        print_status $RED "Error: File not found: $INPUT_FILE"
        exit 1
    fi

    INPUT_TEXT=$(cat "$INPUT_FILE")

elif [ ${#COMMAND_ARGS[@]} -gt 0 ]; then
    # Execute command and capture output
    if [ "$QUIET" != "true" ]; then
        print_status $BLUE "Executing command: ${COMMAND_ARGS[*]}"
    fi

    INPUT_TEXT=$("${COMMAND_ARGS[@]}" 2>&1)
    COMMAND_EXIT_CODE=$?

    if [ $COMMAND_EXIT_CODE -ne 0 ]; then
        if [ "$QUIET" != "true" ]; then
            print_status $RED "Warning: Command exited with code $COMMAND_EXIT_CODE"
        fi
    fi

elif [ ! -t 0 ]; then
    # Read from stdin (pipe)
    INPUT_TEXT=$(cat)

else
    # No input provided
    print_status $RED "Error: No input provided"
    echo ""
    show_usage
    exit 1
fi

# Parse the input
if [ "$QUIET" != "true" ]; then
    print_status $BLUE "Parsing ZI output..."
fi

PARSED_OUTPUT=$(parse_zi_output "$INPUT_TEXT" "$QUIET")
PARSE_EXIT_CODE=$?

if [ $PARSE_EXIT_CODE -ne 0 ]; then
    exit 1
fi

# Output the result
if [ "$RAW_OUTPUT" = true ]; then
    echo -n "$PARSED_OUTPUT"
else
    echo "$PARSED_OUTPUT"
fi

# Copy to clipboard if requested
if [ "$COPY_TO_CLIPBOARD" = true ]; then
    echo -n "$PARSED_OUTPUT" | xclip -selection clipboard
    if [ "$QUIET" != "true" ]; then
        print_status $GREEN "✓ Output copied to clipboard"
    fi
fi

if [ "$QUIET" != "true" ]; then
    print_status $GREEN "✓ Parsing completed successfully"
fi
