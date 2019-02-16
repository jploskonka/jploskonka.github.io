---
title: How to run application before CodeceptJS tests.
description: A short guide on how to automatically run local application before CodeceptJS tests suite.
keywords: codeceptjs tutorial, codeceptjs bootstrap, codeceptjs before tests, codeceptjs run application, codeceptjs how to run app, how to run app with codeceptjs, codeceptjs testing, acceptance testing with codeceptjs, testing, test, javascript
date: 2017-11-21
---

In my last post I was writing about [testing TodoMVC application with
CodeceptJS](http://codenroll.it/acceptance-testing-with-codecept-js/). For sake
of simplicity I've used online version of [TodoMVC vanillajs
example](http://todomvc.com/examples/vanillajs/) and I've been running my tests
right on the project website. It might've been good enough for course of the
tutorial but it's not very real-world use case—you don't want to mess around
with the production environment from your tests. Instead of that it'd be
good to automatically run the application just before running test suite and
then shut it down when testing is done.

## tl;dr
Checkout sample repository
[here](https://github.com/jploskonka/testing-with-codeceptjs)


## How?
Codecept provides [bootstrap](http://codecept.io/basics/#bootstrap) and
[teardown](http://codecept.io/basics/#teardown) hooks executed respectively
before and after all tests. Those are perfect for use case like this one.

In `Bootstrap` hook I'll use node's `child_process.exec` method to run
application. After it I have to block tests execution until app is ready to
receive requests and send some response.

Then in `Teardown` part I'll kill application with usage of
[ps-tree](https://www.npmjs.com/package/ps-tree) package.
I can't use native nodes [`child_process.kill`](https://nodejs.org/api/child_process.html#child_process_child_kill_signal)
because it would kill only child process itself. However `child_process.exec`
doesn't spawn application as tests process child—it spawns shell inside which
command is executed. So application is actually a child of a child of codeceptjs
process. What is interesting here is that application itself can spawn multiple
next processes and those also needs to be killed.

In order to keep track of http server process and to keep bootstrap/teardown
hooks code cleaner I'm gonna create `AppManager` class which I'd like to use
like this:

``` js
// Initialize with some config:
appManager = new AppManager({
  host: 'http://example.com', 
  port: 3000,
})

// To start application:
appManager.start()

// And to shut-down application
appManager.close()
```

Let's start by creating `support` directory where I'd put `AppManager.js`,
`bootstrap.js` and `teardown.js` files:

``` shell
$ mkdir support
# And create empty file there
$ touch support/appManager.js support/bootstrap.js support/teardown.js
```

Now it's time for `AppManager` class, start with constructor:

``` js
// support/appManager.js

const defaultConfig = {
  host: 'localhost',
  port: 3000,
  appCommand: 'yarn app'
};

// How long to wait for app to start.
const APP_TIMEOUT = 4000;

class AppManager {
  constructor(config) {
    // Used to keep reference to app process
    this._app = null;

    // Merge config with defaultConfig
    this.config = Object.assign(defaultConfig, config);
  }
};

const appManager = new AppManager({});

module.exports = appManager;
```

I'm exporting instance of `AppManager` not class, to easily require it in
multiple places and still get the same object. If I created new instance in
different modules I'd lost track of `app` property and won't be able to close
it during teardown.

Next thing is to create `start` method. To wait until app is ready I'm using
[`tcp-port-used`](https://www.npmjs.com/package/tcp-port-used) package, so start
by adding it:

``` shell
$ yarn add tcp-port-used
```

And finally implement the `start` method:

``` js
// support/appManager.js
const cp = require('child_process');
const tcpPortUsed = require('tcp-port-used');

class AppManager {
  // ...

  start(callback) {
    console.log(`Starting app at: ${this.config.host}:${this.config.port}`);

    // Spawn shell and execute appCommand
    this.app = cp.exec(this.config.appCommand);

    // Block execution of tests till app is upp
    this.waitForApp(callback);
  }

  _waitForApp(callback) {
    // third argument to waitUntilUsedOnHost is interval
    // how often it should check if app is already started.
    tcpPortUsed
      .waitUntilUsedOnHost(this.config.port, this.config.host, 500, APP_TIMEOUT)
      .then(() => {
        console.log(`Application started, running tests.`);
        callback();
      });
  }
}
```

And `bootstrap.js` file:

``` js
// bootstrap.js
const appManager = require('./appManager.js');

module.exports = function(done) {
  appManager.start(done);
}
```

By exporting function with `done` attribute from bootstrap file we tell Codecept
that it should wait with proceeding further until `done` callback is called. So
I'm passing it to `start` method where it's executed after application is up.

Finally add locations of bootstrap and teardown files in `codecept.json` file
and update Nightmare URL to match local application:

``` js
// codecept.json
// ...
  "Nightmare": {
    "url": "http://localhost:8080/"
  },
// ...
"bootstrap": "./support/bootstrap.js",
"teardown": "./support/teardown.js",
"mocha": {},
```

Super, let's run our tests and see what happens:

``` js
$ yarn run test
```

It looks OK, application is started as expected and first test waits for it.
After last scenario it freezes forever because we didn't kill it and Codecept
still thinks there's something going on.

### Clean up on teardown
Start with adding `ps-tree` dependency:

``` shell
$ yarn add ps-tree
```

Now comes the `close` method of `AppManager` class:

``` js
// support/appManager.js
const psTree = require('ps-tree');

class AppManager {
  // ...
  close() {
    psTree(this.app.pid, (err, children) => {
      const pids = children.map(p => p.PID);

      cp.spawn('kill', ['-9'].concat(pids));
    });
  }
}
```

Yeah, that's all! `psTree` gets app process pid, then it passes array of
children processes as second callback parameter. By killing all of them I'm
sure there won't be any orphaned process left running in the background.

I'm using `kill -9` here because I don't need to worry about gracefully shutting
down application. However in real-world use case it may be a good idea to
consider using `SIGTERM` to handle shutting down.

Last thing is to call our `close` from teardown hook:

``` js
// support/teardown.js
const appManager = require('./appManager.js');

module.exports = function() {
  appManager.close();
}
```

## Possible improvements
Basically that's it. For complete production usage you'd probably want to pass
host and port to application when starting it, I'd also think about keeping
config in separate module and then using [codecept's dynamic
config](http://codecept.io/configuration/#dynamic-configuration) file to also
get necessary details from it.

For CI integration it may be useful to pass some data as environment variables,
this could be easily done when creating `AppManager` instance, for example:

``` js
const config = {
  host: process.env.APP_HOST,
  port: process.env.APP_PORT,
  appPath: '../some/path/to/app/dir',
  appCommand: 'run my app'
}

const appManager = new AppManager(config);
```

Too see working example you can checkout code
[here](https://github.com/jploskonka/testing-with-codeceptjs).

Thanks for reading!
