echo
echo "Push to GitHub"
git push

echo
echo "Push to Heroku"
git push heroku master

echo
echo "Restart local server"
sh run.sh

echo 