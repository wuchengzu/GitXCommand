#!/bin/bash
git show $(comm -1 -2 <(git rev-list $1..$2 --ancestry-path) <(git rev-list $1..$2 --first-parent))
