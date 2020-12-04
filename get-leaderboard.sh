#!/usr/bin/env bash

curl \
    -H "Cookie: $(cat cookie)" \
    'https://adventofcode.com/2020/leaderboard/private/view/382101.json' \
    > leaderboard
