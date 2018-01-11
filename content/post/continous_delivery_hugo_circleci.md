---
title: Continuous delivery of Hugo with Docker, CircleCI and Github Pages.
description: Guide showing how to setup continuous delivery for Hugo project with Docker and CircleCI.
keywords: Hugo, gohugo, hugo circleci, hugo continuous delivery, hugo with docker, hugo circleci docker, hugo circle docker
date: 2018-01-11
---

I'm huge fan of [Hugo](https://gohugo.io/) - static site generator written in
Go. It powers this blog and it became my go to tool for statically generated
webpages. I like [Github Pages](https://pages.github.com/) as place to host
such projects for it's simplicity and I'm using Github anyway so I don't need to
setup separate service for hosting. I'm also big fan of automating boring and
repetitive tasks and deploying project to Github Pages definitely is not
fascinating thing to do.

To make things more interesting and pleasant to work with I decided to automate
deployments so that every time I push some code to Github I get new version
built and published automatically.

As CI server I chose [CircleCI](https://circleci.com/) and for keeping
development and CI environments portable and as similar to each other as
possible I'm gonna use Docker. This way I won't even need to install Hugo
locally :D

## tl;dr
Checkout source code for this blog
[here](https://github.com/jploskonka/jploskonka.github.io).

## Dependencies
[Docker](https://www.docker.com/community-edition#/download) and
[docker-compose](https://docs.docker.com/compose/install/).

I'm using following versions:
``` sh
$ docker -v
# Docker version 17.09.0-ce, build afdb6d4

$ docker-compose -v
# docker-compose version 1.16.1, build 6d1ac21
```

I assume you already have Hugo project to work with, if not then please follow
[QuickStart guide](https://gohugo.io/getting-started/quick-start/) to create
one. For instructions on how to setup it with Github pages checkout docs
[here](https://help.github.com/categories/github-pages-basics/).

## Git branching flow
I'm using Hugo with User project and because of that Github requires page to be
published from `master` branch. As main branch I'm using `source` and I'm
checking out feature branches from it. You can think of it as `master` in
“standard” git flow. If you're working on Project Pages it's common to publish
website from `gh-pages` branch and use `master` one in “normal” way. For
differences between Organisation/User and Project Pages checkout [this
guide](https://help.github.com/articles/user-organization-and-project-pages/).

## Development environment
First necessary thing to do is to create easy to use development environment.
Thankfully there's already well prepared Docker image for Hugo which I'm gonna
use:
[https://hub.docker.com/r/jguyomard/hugo-builder/](https://hub.docker.com/r/jguyomard/hugo-builder/).

Let's start by adding `docker-compose.yml` file in Hugo project main directory:

```yml
version: '3.4'

services:
  hugo:
    image: jguyomard/hugo-builder:0.32
    entrypoint: hugo
    volumes:
      - .:/src

  server:
    image: jguyomard/hugo-builder:0.32
    command: hugo server --bind 0.0.0.0
    ports:
      - "1313:1313"
    volumes:
      - .:/src
```

First service (`hugo`) is just Hugo binary which when invoked builds page into
`public` directory. `/src` is working directory inside docker container where
all commands are executed. I'm mounting current directory as volume there so
Hugo can see our codebase. Also by setting `entrypoint` to `hugo` you can use
this service to run any `hugo` command like `hugo help`, `hugo benchmark` etc.
almost like you had it installed locally.

Second one (`server`) runs Hugo development server, binds it to
[`0.0.0.0`](https://en.wikipedia.org/wiki/0.0.0.0) address in order to accept
requests from outside container.

Services can be used as follows:

```sh
# To build page:
$ docker-compose run hugo

# To use hugo commands:
$ docker-compose run hugo benchmark

# You can pass command line flags too:
$ docker-compose run hugo benchmark --help

# To run development server:
$ docker-compose up server
```

Awesome! With just few lines of code you're now sure that every developer who
works on project will have exact same version of Hugo by using provided
services, page will be always build in the same way and if you for example
update to new Hugo version everyone will know about it by looking at source
code.

## publish_to_ghpages script
OK we can easily build our webpage, now it's time to publish changes to Github
Pages. Idea here is to checkout `master` branch into `public` directory, clean it,
generate new version of page into it, commit changes to git and finally push
it to Github.

Create new file called `publish_to_ghpages` in project main directory with
following code in it:

``` sh
#!/usr/bin/env bash

# Exit script if any command in it happens to fail
set -e

# Prevent accidentally publishing uncommited changes
if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

# Remove public directory and clean information about git worktrees
echo "Deleting old publication"
rm -rf public
git worktree prune

# Checkout current master branch into public directory
echo "Checking out master branch into public"
git worktree add -B master public origin/master

# After checkout you'll have current page version, remove it
# before building new one
echo "Removing existing files"
rm -rf public/*

echo "Generating site into public directory"
docker-compose run hugo

# If you're not using custom domain or don't need CNAME
# file you can just remove those 2 lines.
echo "Copying CNAME"
cp CNAME public/

# Set timestamp to time in miliseconds from epoch
# It's gonna be used to tag release.
timestamp=$(date +%s%3N)
echo "Publishing version $timestamp"

# Commit everything in public dir, push changes and add git tag to it.
cd public && \
  git add --all && \
  git commit -m "publish_to_ghpages" && \
  git tag "$timestamp" && \
  git push origin master && \
  git push origin "$timestamp"


echo "Published version $timestamp"
```

Save file, exit and mark it as executable file:

``` sh
$ chmod +x ./publish_to_ghpages
```

Beautiful. Now you can easily publish your page from local machine by executing:

``` sh
$ ./publish_to_ghpages
```

## Automating deployments with CircleCI
Before going further make sure to setup your project on CircleCI, [here's
official guide](https://circleci.com/docs/2.0/).

### Create SSH key with write access to your repository
When you setup your project on CircleCI it get's only read access to Github
repository. While it's sufficient in most cases this time we want to be able to
also push to this repository from inside a build job. To allow CircleCI to do it
you need to create additional SSH key with write access to repository.

Generate new key with:

``` sh
$ ssh-keygen -t rsa -b 4096 -N '' -f ./circle_key
```

This will create `circle_key` and `circle_key.pub` file in current directory.
Now follow [this
guide](https://developer.github.com/v3/guides/managing-deploy-keys/#setup-2) and
add **public** (`circle_key.pub`) key to your Github repository. Make sure to
check `Allow write access` option.

Then open your CircleCI project settings, go to `SSH Permissions` page, click
`Add SSH key` and paste your **private** (`circle_key`) key. Enter `github.com`
into `hostname` field. After you added your key you can see it's fingerprint on
list. Copy it or leave page open - you will need to enter it into circle config.

[Here's](https://circleci.com/docs/1.0/adding-read-write-deployment-key/)
CircleCI docs on this topic.

You can now safely remove `circle_key` and `circle_key.pub` files or save them
in safe location if you want. **Don't commit those files to your repository.**

### Configuration
CircleCI uses configuration stored in `.circleci/config.yml` file. Let's create
it and add simple config:

``` yml
version: 2

# Publish only changes pushed to `source` branch.
general:
  branches:
    only:
      - source # Put `master` here if it's your main branch

jobs:
  build:
    docker:
      # Set build environment to use same docker image as local docker-compose
      - image: jguyomard/hugo-builder:0.32

    steps:
      # Inject created SSH key into container
      # Remember key added before? Here's place to put it's fingerprint
      - add_ssh_keys:
          fingerprint: YOUR_SSH_KEY_FINGERPRINT

      # Configure git to be able to push
      - run: git config --global user.email bot@example.com
      - run: git config --global user.name CircleCI

      # Checkout source code
      - checkout

      # Run publish script :-)
      - run: .circleci/publish_to_ghpages
```

Now I suggest to move previously created `publish_to_ghpages` script to
`.circleci` directory. I like to do it to emphasize that this script should be
used only via CI server and not from local machine.

``` sh
$ mv publish_to_ghpages ./.circleci
```

### Tweak publish_to_ghpages
Last thing left is to update publish script a bit to work with Circle:

#### Shebang
Update shebang in first line from `#!/usr/bin/env bash` to `#!/bin/sh`.  There's
no bash in container I'm using so circle cannot use it too. Script is simple
enough that it doesn't make much difference to use `sh`. Please remember though:
[**sh is not
bash**](http://mywiki.wooledge.org/BashGuide/CommandsAndArguments#Scripts).

#### No docker-compose
Instead of using `docker-compose run hugo` to build page we need to use just
`hugo` command. Because script is run inside docker container it's safe to do
that, plus we can't use docker-compose commands inside it anyway. So this part:

``` sh
echo "Generating site into public directory"
docker-compose run hugo
```

becomes this:

``` sh
echo "Generating site into public directory"
hugo
```

#### Prevent building master branch
Even though we set that we want to build only `source` branch CircleCI would
still try to build `master`. It happens because there's no `.circle` directory
present in built page so those builds will always fail. To prevent that just
copy it into `public` after building page, for example after `CNAME` section:

``` sh
echo "Copying circleCI config"
cp -R .circleci public/
```

#### Final publish_to_ghpages script
After tweaks our file looks like this:

``` sh
#!/bin/sh

set -e

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
git worktree prune

echo "Checking out master branch into public"
git worktree add -B master public origin/master

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "Copying CNAME"
cp CNAME public/

echo "Copying circleCI config"
cp -R .circleci public/

timestamp=$(date +%s%3N)

echo "Publishing version $timestamp"
cd public && \
  git add --all && \
  git commit -m "publish_to_ghpages" && \
  git tag "$timestamp" && \
  git push origin master && \
  git push origin "$timestamp"
```

## Done!
That's it. Now whenever you push commits to your `source` branch it will trigger
CircleCI build to publish your changes automatically. [It's a kind of
magic!](https://www.youtube.com/watch?v=0p_1QSUsbsM)

Your sample workflow can look like this:

``` sh
# Open your project
$ cd your_project

# Make sure you're on main branch
$ git checkout source

# Checkout to new feature branch
$ git checkout -b my_new_post

# [ ... ] Do some changes, create post, whatever

# Commit all your changes
$ git commit -am 'Just finished an amazing article'

# Go back to main branch
$ git checkout source

# Merge feature branch into main one
$ git merge my_new_post

# Push changes!
$ git push
```

Of course you can merge changes into your branch in any way you like it (for
example with Github Pull Request) or work straight from your main branch (it's
usually not a good idea).

Hope you enjoyed reading this article and find it helpful :-) Or maybe you're
automating your Hugo builds in different way? Let me know in comments.

### Resources
- [CircleCI docs](https://circleci.com/docs/2.0/)
- [Github Pages docs](https://help.github.com/categories/github-pages-basics/)
- [Hugo docs](https://gohugo.io/documentation/)
