#!/usr/bin/env bash
# Posts a PR status card to Teams.
# Usage: teams-notify.sh <pr_number> "<status text>" <color> [actor_login]
#   color: Good | Warning | Attention | Accent | Default
set -euo pipefail

PR_NUMBER="$1"
STATUS="$2"
COLOR="${3:-Default}"
ACTOR="${4:-}"
REPO="${GITHUB_REPOSITORY:?}"

# GitHub username -> full profile name (e.g. "Hariharan Rethinasabapathi")
display_name() {
  local n
  n=$(gh api "users/$1" --jq '.name // empty' 2>/dev/null || true)
  echo "${n:-$1}"
}

pr=$(gh api "repos/$REPO/pulls/$PR_NUMBER")
title=$(jq -r '.title' <<<"$pr")
url=$(jq -r '.html_url' <<<"$pr")
author_login=$(jq -r '.user.login' <<<"$pr")
branch="$(jq -r '.head.ref' <<<"$pr") → $(jq -r '.base.ref' <<<"$pr")"

# Reviewers = people still requested + people who already reviewed (minus the author)
reviewer_logins=$( {
  jq -r '.requested_reviewers[].login' <<<"$pr"
  gh api "repos/$REPO/pulls/$PR_NUMBER/reviews" --jq '.[].user.login'
} | sort -u | grep -vx "$author_login" || true )

reviewers=""
for login in $reviewer_logins; do
  reviewers+="$(display_name "$login"), "
done
reviewers="${reviewers%, }"
[ -z "$reviewers" ] && reviewers="Not assigned yet"

status_line="$STATUS"
[ -n "$ACTOR" ] && status_line+=" by $(display_name "$ACTOR")"

payload=$(jq -n \
  --arg status "$status_line" \
  --arg color "$COLOR" \
  --arg title "$title" \
  --arg url "$url" \
  --arg reviewers "$reviewers" \
  --arg author "$(display_name "$author_login")" \
  --arg branch "$branch" \
  '{
    type: "message",
    attachments: [{
      contentType: "application/vnd.microsoft.card.adaptive",
      contentUrl: null,
      content: {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        type: "AdaptiveCard",
        version: "1.4",
        msteams: { width: "Full" },
        body: [
          { type: "TextBlock", text: $status, color: $color, weight: "Bolder", size: "Medium", wrap: true },
          { type: "TextBlock", text: $title, weight: "Bolder", wrap: true, spacing: "Medium" },
          { type: "TextBlock", text: ("[" + $url + "](" + $url + ")"), wrap: true, spacing: "None" },
          { type: "FactSet", facts: [
            { title: "Reviewer", value: $reviewers },
            { title: "Author",   value: $author },
            { title: "Branch",   value: $branch }
          ]}
        ],
        actions: [ { type: "Action.OpenUrl", title: "Open PR", url: $url } ]
      }
    }]
  }')

curl -sS -f -X POST \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$TEAMS_WEBHOOK_URL"

echo "Posted to Teams: $status_line — PR #$PR_NUMBER"
