rm latest.dump
heroku pg:backups:capture
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d koko_dev latest.dump
