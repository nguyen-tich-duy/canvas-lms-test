#!/bin/bash

rsync -u .env.dev .env 

source ./.env

rm -rf canvas-src
mkdir -p canvas-src
cd canvas-src 

git clone --depth 1 --shallow-submodules --branch $CANVAS_REFS $CANVAS_GITURL .
