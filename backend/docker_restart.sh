#!/usr/bin/env bash

function stopAll {
    echo "stopping all containers..."
    docker stop $(docker ps -aq)
}

function build {
    echo "building image..."
    docker build -t nerdjokes .
}
    

function start {
    echo "launching container"
    docker run -p 80:80 -t nerdjokes
}

stopAll
build
start
