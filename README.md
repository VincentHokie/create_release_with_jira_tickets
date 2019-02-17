# Create release with_jira_tickets

Script to automatically create a release in your github repo based on the jira tickets that were completed from the last two release tags.

## Command line tool dependancies

- jira-cli
- jq

## Setup

1. Get you a personal GitHub [token](https://github.com/settings/tokens/new)
2. Give your token full rights over the "repo" scope

## Use

### Ensure to set the following in the script

- `GITHUB_ORGANIZATION`
- `GITHUB_REPOSITORY`
- `GITHUB_ACCESS_TOKEN`
- `ORGANIZATION`

To hit it off, simply run './create_release.sh' if you're in the same directory as the script or `<path-to-script-directory>/create_release.sh`

#

This is work inspired by the script created [here](https://github.com/reactiveops/release.sh).