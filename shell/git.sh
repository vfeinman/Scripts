#!/bin/bash

ghe_auth="Authorization: Basic c3ZjLUJzZERpZ2l0YWxDaUNkOmJkNzg5ZDE0MDg0ZThjNGRlOWM3NGNmMmJmOWU0NjI5MTVjNTY5NzQ="


###############################################################################
# Summary: Removes all of the repos in the specified org that match a pattern 
# Required Positional Argument: 
#   $url - The url of GHE
#   $auth - The complete auth header
#   $org - The name of the GHE org
#   $pattern - The RE pattern to match against repo names
# Returns: Prints the list of usernamess 
###############################################################################
remove_all_ghe_repos()
{
    # https://developer.github.com/enterprise/2.19/v3/orgs/members/#list-your-organization-memberships
    ghe_url="$1"
    auth="$2"
    org="$3"

    repo_names=$(get_ghe_org_repos "$ghe_url" "$auth" "$org")
    while IFS= read -r repo; do 
        echo "Deleting repo $repo"
        curl -X DELETE \
            "https://github.comcast.com/api/v3/repos/bsd-digital-prod/$repo" \
            -H "$ghe_auth"
    done <<<"$repo_names"
}

###############################################################################
# Summary: Gets a list of all repos that belong to an org. 
# Required Positional Argument: 
#   $url - The url of GHE
#   $auth - The complete auth header
#   $org - The name of the GHE org
# Returns: Prints the list of usernamess 
###############################################################################
get_ghe_org_repos()
{
    # https://developer.github.com/enterprise/2.19/v3/orgs/members/#list-your-organization-memberships
    ghe_url="$1"
    auth="$2"
    org="$3"
    # clear any previous results
    cat /dev/null > repos.log
    url="$ghe_url/api/v3/orgs/$org/repos"
    while [ "$url" ]; do
        curl -s -D headers.txt -X GET "$url" -H "$auth" | jq .[].name -r
        url=
        while IFS=', ' read -r -d ", " ADDR; do
            [[ "$ADDR" =~ next ]] && url="$(echo "$ADDR" | sed -E 's/.*<(.*)>; rel="next".*/\1/')" 
        done < <(cat headers.txt | grep -E "^Link")
    done
    cat repos.log
    rm -rf repos.log headers.txt
}

###############################################################################
# Summary: Gets a list of all users that belong to an org. 
# Required Positional Argument: 
#   $url - The url of GHE
#   $auth - The complete auth header
#   $org - The name of the GHE org
# Returns: Prints the list of usernamess 
###############################################################################
get_ghe_org_users()
{
    # https://developer.github.com/enterprise/2.19/v3/orgs/members/#list-your-organization-memberships
    ghe_url="$1"
    auth="$2"
    org="$3"
    # clear any previous results
    cat /dev/null > users.log
    url="$ghe_url/api/v3/orgs/$org/members"
    while [ "$url" ]; do
        curl -s -D headers.txt -X GET "$url" -H "$auth" | jq .[].login -r >> users.log
        url=
        while IFS=', ' read -r -d ", " ADDR; do
            [[ "$ADDR" =~ next ]] && url="$(echo "$ADDR" | sed -E 's/.*<(.*)>; rel="next".*/\1/')" 
        done < <(cat headers.txt | grep -E "^Link")
    done
    cat users.log
    rm -rf users.log headers.txt
}

###############################################################################
# Summary: Adds the list of users passed to the GHE org. 
# Required Positional Argument: 
#   $url - The url of GHE
#   $auth - The complete auth header
#   $org - The name of the GHE org
#   $users - The name of the GHE org
# Returns: n/a 
###############################################################################
add_members_to_ghe_org()
{
    # https://developer.github.com/enterprise/2.19/v3/orgs/members/#add-or-update-organization-membership
    ghe_url="$1"
    auth="$2"
    org="$3"
    users="$4"
    [ -r "$users" ] && users="$(cat $users)"
    while IFS= read -r username; do
        curl -s -X PUT "$ghe_url/api/v3/orgs/$org/memberships/$username" -H "$auth" --data-raw '{"role": "admin"}'
    done <<< "$users"
}

# add_members_to_ghe_org "https://github.comcast.com" "$ghe_auth" "bsd-digital-prod" <(get_ghe_org_users "https://github.comcast.com" "$ghe_auth" "bsd-digital" | grep -E "^\w{6}\d{3}c?$")
# get_ghe_org_repos "https://github.comcast.com" "$ghe_auth" "bsd-digital-prod"