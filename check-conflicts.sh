#!/usr/bin/env bash
# Checks open PRs for merge conflicts and posts to Teams only when the
# conflict state CHANGES. A "has-conflict" label on the PR remembers the
# last state, so the channel isn't spammed on every push.
set -euo pipefail

LABEL="has-conflict"
gh label create "$LABEL" --color D93F0B --description "PR has merge conflicts" --force >/dev/null

# One PR (new commits pushed to it) or all open PRs (target branch moved)
if [ -n "${PR_NUMBER:-}" ]; then
  prs="$PR_NUMBER"
else
  prs=$(gh pr list --state open --limit 100 --json number,isDraft \
        --jq '.[] | select(.isDraft | not) | .number')
fi

# GitHub computes mergeability in the background; give it a moment
sleep 15

for n in $prs; do
  state="unknown"
  for _ in 1 2 3 4 5 6; do
    state=$(gh api "repos/$GITHUB_REPOSITORY/pulls/$n" --jq '.mergeable_state')
    [ "$state" != "unknown" ] && break
    sleep 5
  done

  has_label=$(gh pr view "$n" --json labels \
              --jq "[.labels[].name] | index(\"$LABEL\") != null")

  if [ "$state" = "dirty" ] && [ "$has_label" = "false" ]; then
    gh pr edit "$n" --add-label "$LABEL"
    bash .github/scripts/teams-notify.sh "$n" "⚠️ Merge conflict — please resolve" Attention
  elif [ "$state" != "dirty" ] && [ "$state" != "unknown" ] && [ "$has_label" = "true" ]; then
    gh pr edit "$n" --remove-label "$LABEL"
    bash .github/scripts/teams-notify.sh "$n" "🔧 Conflict resolved" Good
  else
    echo "PR #$n: $state (no change)"
  fi
done
