#!/bin/bash
# Setup:
# 1. Get you a personal GitHub token (https://github.com/settings/tokens/new)
# 2. Give your token full rights over the "repo" scope

log-fail() {
  declare desc="log fail formatter"
  echo "$@" 1>&2
  exit 1
}

check_required_variables() {
    [[ -z "$GITHUB_ACCESS_TOKEN" ]] && log-fail "You must specify a GITHUB_ACCESS_TOKEN environment variable"
    [[ -z "$GITHUB_ORGANIZATION" ]] && log-fail "You must specify a GITHUB_ORGANIZATION environment variable"
    [[ -z "$GITHUB_REPOSITORY" ]] && log-fail "You must specify a GITHUB_REPOSITORY environment variable"
    [[ -z "$ORGANIZATION" ]] && log-fail "You must specify a jira ORGANIZATION environment variable"
    [[ -z "$REPOS" ]] && log-fail "You must specify a list of REPOS to get infromation from environment variable"
}

check_jq() {
    if ! [ -x "$(command -v jq)" ]; then
        echo 'Error: jq is not installed.' >&2
        echo 'Install jq then run this script again.' >&2
        exit 1
    fi
}

check_jira_cli() {
    if ! [ -x "$(command -v jira)" ]; then
        echo 'Error: jira cli is not installed.' >&2
        echo 'Follow this https://docs.jiracli.com to get started with the jira cli.' >&2
        exit 1
    fi
}

check_jira_setup() {
    if [ ! -f "$HOME/.jira-cl.json" ]; then
        echo 'Error: jira cli is not set up right.' >&2
        jira
        jira config board --set
    fi
}

get_ticket_in_latest_release(){
    # defines the '_all_tickets' variable that is then used in the get_jira_issue_details
    _current=$(git tag -l --sort=-creatordate | grep -v vTR | grep "^v" | head -1 | tail -1)
    _previous=$(git tag -l --sort=-creatordate | grep -v vTR | grep "^v" | head -2 | tail -1)
    echo "Tickets merged between $_previous and $_current"
    _all_tickets=""
    for repo in $REPOS
        do 
            cd $repo
            _tickets=$(git log $_previous..$_current --graph --decorate --oneline | grep -E -o '/AC-[0-9]{4,}' | grep -E -o 'AC-[0-9]{4,}' | sort -u)
            _all_tickets="$_all_tickets $_tickets"
        done
    _all_tickets=$(echo $_all_tickets | tr " " "\n" | sort -u)
}

get_jira_issue_details(){
    # this is where you'd customize the format of your release body
    touch .release.txt
    echo "## Tickets in this release:" >> .release.txt
    for issue in $@
        do
            echo -n "Getting $issue details.."
            echo -n "* [$issue](https://${ORGANIZATION}.atlassian.net/browse/$issue) - " >> .release.txt
            jira issue $issue | egrep 'Summary' | awk '{out=$6; for(i=7;i<=NF;i++){out=out" "$i}; print out}' >> .release.txt # leave out the color codes in the string
            echo "Done."
        done
}

create_release_doc() {
    TAG_NAME="$_current"
    echo "Found tag: ${TAG_NAME}"
    
    SUBJECT="Draft ${TAG_NAME} release subject"
    DESCRIPTION="$(cat .release.txt)"

    echo "Release name: ${SUBJECT}"
    echo "Release description: ${DESCRIPTION}"

    REQUEST_BODY="$(jq -n --arg tag_name "$TAG_NAME" --arg subject "${SUBJECT}" --arg description "${DESCRIPTION}" \
    '{"tag_name": $tag_name, "target_commitish": "master", "name": $subject, "body": $description, "draft": true, "prerelease": false} ')"

    echo "Creating release doc.."
    gh_response=$(curl --data "${REQUEST_BODY}" "https://api.github.com/repos/${GITHUB_ORGANIZATION}/${GITHUB_REPOSITORY}/releases?access_token=${GITHUB_ACCESS_TOKEN}")
    echo "You can see your draft release at: "
    echo $gh_response | jq '.html_url'

}

cleanup() {
    rm -f .release.txt
}

main() {
    check_required_variables
    check_jq
    check_jira_cli
    check_jira_setup
    get_ticket_in_latest_release
    get_jira_issue_details $_all_tickets
    create_release_doc
    cleanup
}

main "$@"