echo
echo "Remove latest dump and capturing database at Heroku"
rm latest.dump
heroku pg:backups:capture

echo
echo "Downloading backup"
heroku pg:backups:download

echo
echo "Loading backup into local database"
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d koko_dev latest.dump

echo
