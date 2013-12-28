#!/bin/sh
# get publish message to use
message=$1
if [ -z "$1" ] 
then #if argument is empty
   #get the last commit message from this branch and use it as the commit to publish the site
   message=$(git log -n 1 --format="%s %n %n %b")
fi
# generate - just to make sure latest changes have been built
jekyll build --trace
#push the current branch to remote
git push
# get branch name into $branch -http://git-blame.blogspot.co.uk/2013/06/checking-current-branch-programatically.html
branch=$(git symbolic-ref --short -q HEAD)
#remove /tmp/jsc
rm -rf /tmp/jsc
# create /tmp/jsc
mkdir /tmp/jsc
#copy _site to /tmp/jsc
cp -r _site/. /tmp/jsc/
#checkout gh-pages
git checkout gh-pages
current_branch=$(git symbolic-ref --short -q HEAD)
if [[ "$current_branch" == *gh-pages* ]]
then
	#copy /tmp/jsc/* to current dir, replacing existing files
	cp -rv /tmp/jsc/. .
	# commit changes with message from command line or last commit msg
	git add -u
	git add .
	git commit -a -m ${message}
	# push gh-pages branch
	git push
	# checkout $branch
	git checkout ${branch}
else
  red='\e[0;31m' #red - http://stackoverflow.com/a/5947802/400048
  NC='\e[0m' # No Color
  echo -e "${red}Failed to checkout gh-pages branch, site not published!${NC}"
fi
# remove /tmp/jsc
rm -rf /tmp/jsc
