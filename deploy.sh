#!/bin/bash

git config credential.helper "store --file=.git/credentials"
echo "https://$GH_TOKEN:@github.com" > .git/credentials	
git remote add live https://github.com/t0yv0/t0yv0.github.io.git
git config user.name "TravisCI"
git config user.email "anton.tayanovskyy@gmail.com"
git checkout master
git add . *.html
git commit -am 'CI build'
git push -u live master
