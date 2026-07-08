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
git branch -M main         # Rename master to main

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

git commit -m "Initial commit"

gh repo create modcron --private --source=. --remote=origin --push

gh repo create arvig-modulo/scheduled_reports --private --source=. --remote=origin --push

## store credentials automatically 

gh auth setup-git

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


# Checking Current Config

git config user.name
git config user.email

# Switching User Globally

git config --global user.name "Briean Truss"
git config --global user.email "briean.j.truss@gmail.com"

git config --global user.name "Briean Truss"
git config --global user.email "btruss@moduloinsights.com"

git config --global user.name "Briean Truss"
git config --global user.email "briean.truss.ra@arvig.com"



# Clone a Repository to VS Code

Open VS Code.

Open the Command Palette (Ctrl+Shift+P on Ubuntu/Linux) and select Git: Clone.

Paste your GitHub repository URL and select a local directory.

When prompted, open the cloned repository in a new workspace

## For Dataform Repos

For changes made in VS Code to reflect in the Google Cloud Dataform console, your GCP Dataform repository must be explicitly linked to the same GitHub repository. Dataform handles this natively using Developer Connect:

In the Google Cloud console, navigate to Dataform and select your repository.  

Go to Settings > Connect with Git.

Set the remote Git protocol to Developer Connect and select Link new repository.  

Choose GitHub as your provider, follow the OAuth flow to authorize the Dataform GitHub App, and select the specific repository.  

Set your default branch (e.g., main) and complete the link.

## Configuring MCP Servers in VS Code

To allow an LLM or AI assistant inside VS Code to inspect, query, or refactor your Dataform/GitHub code, configure an MCP server. You can use the official GitHub MCP Server via Docker, or configure a local workspace server.  

### Option A: Using Workspace Configuration (.vscode/mcp.json)

To make the MCP server active specifically for this Dataform project, create a workspace configuration file.  

In the root of your opened VS Code project, create a directory named .vscode if it doesn't exist.

Create a file named mcp.json inside it (.vscode/mcp.json).

Add the configuration for the GitHub MCP server, providing your GitHub Personal Access Token (PAT) so the server can read the repository:  

{
  "mcpServers": {
    "github-dataform-sync": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN=your_github_pat_here",
        "ghcr.io/github/github-mcp-server"
      ]
    }
  }
}


### Option B: Using Global User Profile Configuration

If you prefer the MCP server to be available across all workspaces:

Open the Command Palette (Ctrl+Shift+P) and run MCP: Open User Configuration.

Paste the JSON block into your global mcp.json file.


## Verify the Setup

In VS Code, open the Extensions view (Ctrl+Shift+X) and ensure your MCP environment or Copilot/Agent view is active.

Look at the MCP SERVERS - INSTALLED panel to confirm github-dataform-sync is running and connected.

You can now use the Chat view (Ctrl+Alt+I) to issue commands such as:

"/github-dataform-sync read the staging definitions in definitions/stg_users.sqlx"

"/github-dataform-sync create a pull request for the updated assertions"

This keeps your local edits in sync with GitHub, triggers compilations correctly in GCP Dataform, and lets your local AI development environment fully comprehend your data architecture.