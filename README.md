# Koko.Umbrella

Database administration
-----------------------


*Update postgres:*

`brew upgrade postgresql`
`brew postgresql-upgrade-database`

*Start and stop server:*

`brew services start postgres`
`brew services stop postgres`
`brew services restart postgres`



ExAws
-----

`iex> ExAws.S3.list_objects("poetrylib") |> ExAws.request`

`ExAws.S3.put_object("poetrylib", "yada.txt", "Yada, yada!") |> ExAws.request`

`ExAws.S3.put_object("noteshare-test", "jxxcarlson/baam/yada.txt", "Yada, yada!") |> ExAws.request`
`
`ExAws.S3.get_object("poetrylib", "alba.txt") |> ExAws.request`


ExAws.S3.get_object("noteshare-text", "jxxcarlson/test/trajectories_and_uncertainty-version10.tex") |> ExAws.request

# http://noteshare-test.s3.amazonaws.com/jxxcarlson/test/trajectories_and_uncertainty-version10.tex
