#!/bin/bash

main() {
    REMOTES="$@";
    if [ -z "$REMOTES" ]; then
        REMOTES=$(git remote);
    fi
    REMOTES=$(echo "$REMOTES" | xargs -n1 echo)
    CLB=$(git rev-parse --abbrev-ref HEAD);
    echo "$REMOTES" | while read REMOTE; do
        git remote update $REMOTE
        git remote show $REMOTE -n \
        | awk '/merges with remote/{print $5" "$1}' \
        | while read RB LB; do
            ARB="refs/remotes/$REMOTE/$RB";
            ALB="refs/heads/$LB";
            NBEHIND=$(( $(git rev-list --count $ALB..$ARB 2>/dev/null) +0));
            NAHEAD=$(( $(git rev-list --count $ARB..$ALB 2>/dev/null) +0));
            if [ "$NBEHIND" -gt 0 ]; then
                if [ "$NAHEAD" -gt 0 ]; then
                    echo " branch $LB is $NBEHIND commit(s) behind and $NAHEAD commit(s) ahead of $REMOTE/$RB. could not be fast-forwarded";
                    elif [ "$LB" = "$CLB" ]; then
                    echo " branch $LB was $NBEHIND commit(s) behind of $REMOTE/$RB. fast-forward merge";
                    git merge -q $ARB;
                else
                    echo " branch $LB was $NBEHIND commit(s) behind of $REMOTE/$RB. resetting local branch to remote";
                    git branch -f $LB -t $ARB >/dev/null;
                fi
            fi
        done
    done
}

main $@
