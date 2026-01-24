# GitHub authentication recipes

# Login to GitHub CLI
gh-auth:
    gh auth login

# Setup git configuration for GitHub
gh-setup-git:
    gh auth setup-git

# Run both GitHub auth commands in sequence
github-setup: gh-auth gh-setup-git
