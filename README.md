# code'n'roll.it
[http://codenroll.it/](http://codenroll.it/)

Source code of my personal blog powered by Hugo.

## Development
Just clone the repo:

``` sh
$ git clone git@github.com:jploskonka/jploskonka.github.io.git
```

And run development server:

``` sh
$ docker-compose up server
```

To build static files:

``` sh
$ docker-compose run hugo
```

## Dependencies
- Docker & docker-compose

## Deployment
Project is setup to automatically deploy `source` branch with CircleCI. Just
merge changes to it and it will soon be deployed.
