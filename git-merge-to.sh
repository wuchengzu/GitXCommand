#!/bin/bash
set -ue
if [ ! -d .git ]; then
	echo "当前目录不是并不是一个git仓库"
	exit
fi

while getopts pb opt; do
	case "$opt" in
	p) opt_push=1 ;;
	b) opt_back=1 ;;
	*)
		echo "error: unknown opt: $opt"
		exit 1
		;;
	esac
done

to_branch=${!OPTIND}
from_branch=$(git rev-parse --abbrev-ref HEAD)

git checkout $to_branch
git pull
git merge $from_branch
if [ -n "${opt_push:-}" ]; then
	git push
fi
if [ -n "${opt_back:-}" ]; then
	git checkout $from_branch
fi
