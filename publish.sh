#!/bin/bash
# get publish message to use
message=$1
if [ -z "$1" ] 
then #if argument is empty
   #get the last commit message from this branch and use it as the commit to publish the site
   message=$(git log -n 1 --format="%s %n %n %b")
fi
#push the current branch to remote
git push
# get branch name into $branch -http://git-blame.blogspot.co.uk/2013/06/checking-current-branch-programatically.html
branch=$(git symbolic-ref --short -q HEAD)
#remove /tmp/jsc
rm -rf /tmp/jsc
# create /tmp/jsc
mkdir /tmp/jsc
#copy _site to /tmp/jsc
cp -r _site/. /tmp/jsc
#checkout gh-pages
git checkout gh-pages
#copy /tmp/jsc/* to current dir, replacing existing files
cp -r /tmp/jsc/. ./
# commit changes with message from command line
git add .
git commit -a -m ${message}
# push gh-pages branch
git push
# checkout $branch
git checkout ${branch}
# remove /tmp/jsc
rm -rf /tmp/jsc
