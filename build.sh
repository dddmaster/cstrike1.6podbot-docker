#!/bin/bash
set -e
image=dddmaster/cstrike1.6podbot
tag=latest

docker login
docker build -t $image:$tag .
docker push $image:$tag
