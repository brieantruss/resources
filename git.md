# Install

sudo apt install gh

## Connect to Github Account

gh auth login

-- select https
-- web browser

https://github.com/btruss13

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

## Branching and Merging

git branch                 # List all branches
git branch <branch_name>   # Create a new branch
git checkout <branch_name> # Switch to a different branch
git merge <branch_name>    # Merge a branch into the current branch

## Other Useful Commands

git log                    # View commit history
git reset --hard HEAD       # Discard all changes in the working directory
git checkout -- <file>     # Discarsd changes to a specific file
git stash                  # Temporarily save changes that aren't ready to be committed
git stash pop              # Restore stashed changes

## GitHub-Specific (using the 'gh' CLI)

gh repo clone <username>/<repository>  # Clone a repository using 'gh'
gh issue create              # Create a new issue
gh pr create                 # Create a new pull request
gh pr list                   # List open pull requests

## Advanced Commands (use with caution)

git rebase <branch_name>   # Re-apply commits on top of another branch (can rewrite history)
git cherry-pick <commit>    # Apply a specific commit from another branch

## My Favorites

git clone <repository_url>  # Download a repository from GitHub
git pull origin main
git add .                  # Stage all changes in the current directory

## Creating a Local Directory and Connecting to GitHub

gh repo create rps --private --clone # Run in the PARENT directory of your new repo 
gh repo create arvig-modulo/rps --private --clone # For adding to a specific organization
cd my-project
git add .
git commit -m "Initial commit"
git push -u origin master

## Merging Changes to Main

git checkout main
git pull origin main
git merge <your-feature-branch-name>

## (Resolve conflicts if any, and then git add and git commit)

git push origin main

## (Optional) 

git branch -d <your-feature-branch-name>

## (Optional) 

git push origin --delete <your-feature-branch-name>

## Get an updated file from the remote repo
git checkout <file_name>
git pull



## Create a Repo from an existing directory

git init

git add .

git commit -m "Initial commit of health stats"

gh repo create health_stats_backups --private --source=. --remote=origin --push

gh repo create arvig-modulo/cap_dash --private --source=. --remote=origin --push

## gh auth login

gh auth login

? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations on this host? SSH
? Upload your SSH public key to your GitHub account? /home/modulo/.ssh/id_ed25519.pub
? Title for your SSH key: modulo-0
? How would you like to authenticate GitHub CLI? Paste an authentication token
Tip: you can generate a Personal Access Token here https://github.com/settings/tokens
The minimum required scopes are 'repo', 'read:org', 'admin:public_key'.
? Paste your authentication token: *********************************************************************************************
- gh config set -h github.com git_protocol ssh
✓ Configured git protocol
! Authentication credentials saved in plain text
HTTP 403: Resource not accessible by personal access token (https://api.github.com/user/keys?per_page=100)
