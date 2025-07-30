#!/usr/bin/env python3
import subprocess
from datetime import datetime, timedelta
import sys
import os
from pathlib import Path
import argparse

def run_git_command(cmd, cwd):
    try:
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, shell=True)
        if result.returncode != 0:
            print(f"Error running command: {cmd}")
            print(f"Error output: {result.stderr}")
            return None
        return result.stdout.strip()
    except Exception as e:
        print(f"Exception running command: {cmd}")
        print(f"Error: {str(e)}")
        return None

def get_worktree_paths():
    driving_path = os.path.expanduser("~/driving")
    cmd = 'git worktree list'
    result = run_git_command(cmd, driving_path)

    if not result:
        return []

    worktrees = [line.split()[0] for line in result.split('\n')]
    return worktrees

def get_branch_name(path):
    cmd = 'git rev-parse --abbrev-ref HEAD'
    result = run_git_command(cmd, path)
    return result if result else "unknown_branch"

def get_git_user():
    cmd = 'git config user.name'
    return run_git_command(cmd, os.getcwd())

def get_commit_full_message(hash_val, path):
    cmd = f'git log -1 --pretty=format:"%B" {hash_val}'
    result = run_git_command(cmd, path)
    return result if result else ""

def get_todays_commits(path):
    git_user = get_git_user()
    if not git_user:
        return []

    # Use reflog to find new commits created today
    cmd = f'''git reflog \
        --pretty=format:"%h|%aI" \
        --grep-reflog="commit:" \
        --author="{git_user}" \
        --since="midnight"'''

    result = run_git_command(cmd, path)

    if not result:
        return []

    commit_list = []
    seen_hashes = set()  # To prevent duplicate commits

    for commit in result.split('\n'):
        if not commit.strip():
            continue

        try:
            hash_val, author_date = commit.split('|')

            # Skip if we've already seen this commit
            if hash_val in seen_hashes:
                continue

            seen_hashes.add(hash_val)

            # Get the full commit message
            full_message = get_commit_full_message(hash_val, path)

            # Parse ISO 8601 date
            author_dt = datetime.fromisoformat(author_date)
            display_time = author_dt.strftime('%H:%M:%S')

            commit_list.append((
                display_time,
                hash_val,
                full_message,
                author_dt
            ))

        except Exception as e:
            print(f"Error parsing commit: {commit}")
            print(f"Error: {str(e)}")
            continue

    return commit_list

def write_commits_to_file(worktrees, output_file):
    today = datetime.now().date()

    with open(output_file, 'a') as f:
        f.write(f"\n\n=== Commits for {today} ===\n")

        for worktree in worktrees:
            commits = get_todays_commits(worktree)
            if commits:
                branch = get_branch_name(worktree)
                worktree_name = os.path.basename(worktree)

                f.write(f"\n[{worktree_name} - {branch}]\n")

                for time, hash_val, message, _ in sorted(commits, key=lambda x: x[3], reverse=True):
                    f.write("-" * 50 + "\n")
                    f.write(f"Time: {time}\n")
                    f.write(f"Hash: {hash_val}\n")
                    f.write("Message:\n")
                    f.write(message.strip() + "\n")


def main():
    parser = argparse.ArgumentParser(description='Summarize new git commits (excluding rebases) across worktrees')
    parser.add_argument('--output',
            default=os.path.expanduser('~/commit_summaries.txt'),
                                   help='Output file path (default: ~/commit_summaries.txt)')
    parser.add_argument('--debug', action='store_true',
                      help='Show debug information')
    args = parser.parse_args()

    today = datetime.now().date()
    print(f"\nYour new commits for {today}:")
    print("(Showing only newly created commits, excluding rebased ones)")
    print()

    worktrees = get_worktree_paths()
    if not worktrees:
        print("No worktrees found!")
        return

    found_commits = False
    for worktree in worktrees:
        commits = get_todays_commits(worktree)
        if commits:
            found_commits = True
            branch = get_branch_name(worktree)
            worktree_name = os.path.basename(worktree)

            print(f"\n[{worktree_name} - {branch}]")

            for time, hash_val, message, _ in sorted(commits, key=lambda x: x[3], reverse=True):
                print("-" * 50)
                print(f"Time: {time}")
                print(f"Hash: {hash_val}")
                print("Message:")
                print(message.strip())

    if found_commits:
        # Write to file
        write_commits_to_file(worktrees, args.output)
        print(f"\nCommit summaries have been appended to: {args.output}")
    if not found_commits:
        print("\nNo new commits found for today in any worktree.")
        if args.debug:
            print("\nTry running this command manually to debug:")
            print(f"cd ~/driving")
            print(f'git reflog --pretty=format:"%h | %aI" --grep-reflog="commit:" --author="$(git config user.name)" --since="midnight"')

if __name__ == "__main__":
    main()
