#!/usr/bin/env bash

git clone git@github.com:idrisr/nerdjokes.git
cd nerdjokes/backend || exit
swift build
./.build/debug/NerdJokesBackend
