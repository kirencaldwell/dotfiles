#!/usr/bin/env python3

import argparse
import sys
from typing import List

def format_pr_text(link: str, observations: List[str]) -> str:
    """
    Formats a link and a list of observations into a Markdown string for a PR description.

    Args:
        link: The URL to the internal tool/visualization.
        observations: A list of strings, where each string is an observation.

    Returns:
        A Markdown-formatted string.
    """
    if not link:
        return "No link provided. Please provide a link to the visualization."

    formatted_observations = ""
    if observations:
        formatted_observations = "\n" + "\n".join(f"* {obs.strip()}" for obs in observations)

    # Use a clear Markdown format for the output
    pr_text = f"""
### What was tested

**Argus Link:** {link}
**Observations:**{formatted_observations}
"""
    return pr_text.strip()

def main():
    """
    Main function to parse command-line arguments and run the formatter.
    """
    parser = argparse.ArgumentParser(
        description="Formats a link and observations for a PR description."
    )

    # Argument for the link
    parser.add_argument(
        "-l", "--link",
        required=True,
        help="The URL to the internal visualization tool."
    )

    # Argument for the observations. nargs='+' allows for one or more arguments.
    parser.add_argument(
        "-o", "--observations",
        nargs='+',
        required=True,
        help="A list of observations from the visualization. Each observation should be a separate string.",
    )

    args = parser.parse_args()

    # Get the formatted text
    pr_text = format_pr_text(args.link, args.observations)

    # Print the formatted text to standard output
    print(pr_text)
    
    # You can also copy the output to the clipboard using an external command,
    # but that requires additional setup. This script just prints the text.

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

