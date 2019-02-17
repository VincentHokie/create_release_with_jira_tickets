# Create release with_jira_tickets

Script to automatically create a release in your github repo based on the jira tickets that were completed from the last two release tags.

## Command line tool dependancies

- jira-cli
- jq

## Setup

1. Get you a personal GitHub [token](https://github.com/settings/tokens/new)
2. Give your token full rights over the "repo" scope

## Use

### Ensure to set the following as environemnt variables

- `GITHUB_ORGANIZATION`
- `GITHUB_REPOSITORY`
- `GITHUB_ACCESS_TOKEN`
- `ORGANIZATION`
- `REPOS`

then run `./create_release.sh`, alternatively set the variables at runtime and run `REPOS="../front-end ../../back-end ./tools" ORGANIZATION='myorg' GITHUB_REPOSITORY='githubreponame' GITHUB_ORGANIZATION='gh_org' GITHUB_ACCESS_TOKEN="supersecuretoken" ./create_release.sh`.


### Sample

Here's an example release message created by the script
![Alt Text](/media/example-release-message.png?raw=true)

#

This is work inspired by the script created [here](https://github.com/reactiveops/release.sh).