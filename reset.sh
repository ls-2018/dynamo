#!/usr/bin/env zsh
eval "$(print_proxy.py)"
git reset --soft f49d6873
git add .
git commit -s -m "x"
git checkout -b cn || true
git remote add ls https://github.com/ls-2018/dynamo.git || true
git push ls --force
git reset --soft f49d6873
