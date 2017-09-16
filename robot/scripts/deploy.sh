color=`tput setaf 48`
reset=`tput setaf 7`

echo
echo "${color}Push to GitHub${reset}"
git push

echo
echo "${color}Push to Heroku${reset}"
git push heroku master

echo
echo "${color}Restart local server${reset}"
sh run.sh

echo
