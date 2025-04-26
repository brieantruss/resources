# Basic Git Commands

git clone <repository_url>  # Download a repository from GitHub
git init                   # Initialize a new Git repository in the current directory

git add <file>             # Stage a file for commit
git add .                  # Stage all changes in the current directory
git add -A                 # Stage all changes (new, modified, deleted)

git commit -m "Your commit message"  # Commit staged changes with a message

git push                   # Push committed changes to the remote repository
git pull                   # Fetch and merge changes from the remote repository

git status                 # Check the status of your working directory
git diff                   # See the differences between your changes and the last commit

# Branching and Merging

git branch                 # List all branches
git branch <branch_name>   # Create a new branch
git checkout <branch_name> # Switch to a different branch
git merge <branch_name>    # Merge a branch into the current branch

# Other Useful Commands

git log                    # View commit history
git reset --hard HEAD       # Discard all changes in the working directory
git checkout -- <file>     # Discard changes to a specific file
git stash                  # Temporarily save changes that aren't ready to be committed
git stash pop              # Restore stashed changes

# GitHub-Specific (using the 'gh' CLI)

gh repo clone <username>/<repository>  # Clone a repository using 'gh'
gh issue create              # Create a new issue
gh pr create                 # Create a new pull request
gh pr list                   # List open pull requests

# Advanced Commands (use with caution)

git rebase <branch_name>   # Re-apply commits on top of another branch (can rewrite history)
git cherry-pick <commit>    # Apply a specific commit from another branch

# My Favorites

git clone <repository_url>  # Download a repository from GitHub
git pull origin main
git add .                  # Stage all changes in the current directory
