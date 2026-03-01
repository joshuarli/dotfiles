function gh_cancel_pr_runs --description "Cancel all active CI runs for the current branch's PR"
    argparse 'r/repo=' -- $argv
    or return 1

    set repo (string join '' $_flag_repo)
    if test -z "$repo"
        set repo (gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
        if test -z "$repo"
            echo "error: could not detect repo; pass --repo owner/name" >&2
            return 1
        end
    end

    # Don't pass --repo here: gh auto-detects from the git remote, which handles forks correctly
    set sha (gh pr view --json headRefOid --jq '.headRefOid' 2>/dev/null)
    if test -z "$sha"
        echo "error: no PR found for current branch in $repo" >&2
        return 1
    end

    set run_ids (gh run list \
        --repo $repo \
        --commit $sha \
        --json databaseId,status \
        --jq '.[] | select(.status != "completed") | .databaseId')

    if test -z "$run_ids"
        echo "no active runs found for $sha"
        return 0
    end

    for id in $run_ids
        echo "cancelling run $id..."
        gh run cancel $id --repo $repo
    end
end
