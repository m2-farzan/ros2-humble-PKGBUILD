#!/bin/bash
git checkout master
shared_commits=`~/px "filter(lambda c: c in x, y)" <(git --no-pager log --pretty=format:%s extended) <(git --no-pager log --pretty=format:%s master)`
new_commits=`~/px "y[0: x.index(z[0])][::-1]" <(git --no-pager log --pretty=format:%s extended) <(git --no-pager log --pretty=format:%h extended) <(printf "${shared_commits}")`
for commit in ${new_commits}; do
    commit_msg=`~/px "x[y.index(z[0])]" <(git --no-pager log --pretty=format:%s extended) <(git --no-pager log --pretty=format:%h extended) <(echo ${commit})`
    changed_files=`git diff --name-only ${commit}^ ${commit}`
    is_gitignored=`~/px --bo -ipathspec "[PathSpec.from_lines('gitwildmatch', y).match_file(filename) for filename in x]" <(printf "${changed_files}") <(git show origin/extended:.aurignore)`
    is_consistent=`~/px --bi "(sum(x) * sum([not _x for _x in x])) == 0" - <<< "${is_gitignored}"` # All gitignored or none gitignored
    if [ ${is_consistent} == "False" ]; then
        echo "Some files are gitignored but not all of them. Manual rebase needed."
        exit 1
    fi
    keep_commit=`printf ${is_gitignored} | ~/px --bi "sum(x) == 0" -`
    if [ ${keep_commit} == "False" ]; then
        echo "** Skipping ${commit_msg} (${commit})"
    else
        echo "** Rebasing ${commit_msg} (${commit})"
        git cherry-pick ${commit}
    fi
    echo "Debug info for this commit:"
    echo "  Changed Files: ${changed_files}"
    echo "  Gitignored Matrix: $(printf ${is_gitignored} | ~/px --bi -L '[1 if x else 0]' -)"
    echo "  Is Consistent: ${is_consistent}"
    echo "  Keep Commit: ${keep_commit}"
done
exit 0
