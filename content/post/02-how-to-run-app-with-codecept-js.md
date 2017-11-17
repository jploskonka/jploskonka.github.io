---
title: Running application before CodeceptJS tests
date: "2017-07-12T17:12:33.962Z"
draft: true
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

And that's exactly what I'm gonna show you today. Let's start!

## Sample application
I'm gonna use very simple ExpressJS application that just renders `Hello world`
on homepage. Let's start by creating new directory and initializing yarn project
in it:

``` shell
yarn init -y
```

Now add `express` dependency:

``` shell
yarn add express
```

And create `app.js` file with our simple application:

```js
// app.js
const express = require('express');
const app = express();

const APP_PORT = process.env.APP_PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(PORT, () => {
  console.log(`Application listening at port: ${APP_PORT}`);
});
```

To run application use:
``` shell
node app.js
```

If everything works OK you can visit
[http://localhost:3000](http://localhost:3000) and you should see the `Hello
world` text.

## Running application with tests
### The idea
Now that it's possible to easily run local application let's glue it together
with Codecept so every time when the `yarn run test` command is ussed
it'd automatically run our http server with TodoMVC. It also should shut down
the app when tests are done.

### How?
Codecept provides [bootstrap](http://codecept.io/basics/#bootstrap) and
[teardown](http://codecept.io/basics/#teardown) hooks that're executed once
before and after all tests. Those are perfect for use case like this one.

In `Bootstrap` hook I'll use node's `child_process.exec` method to spawn a new
shell and execute there command to run web application. In the meantime I have
to wait with running first scenario as long as my server is not yet responding.

Then in `Teardown` part I'll kill spawned shell and all of it's children with
usage of [ps-tree](https://www.npmjs.com/package/ps-tree) package. I can't use
native node's
[`child_process.kill`](https://nodejs.org/api/child_process.html#child_process_child_kill_signal)
because it'd kill only first child of our process—which in this case would be
shell spawned by `exec` and application would be still running.

In order to keep track of http server process and to keep bootstrap/teardown
hooks code cleaner I'm gonna create `AppManager` class which I'd like to use
like this:

``` js
// Initialize with some config:
appManager = new AppManager({
  host: 'http://example.com', port: 3000
})

// To start application:
appManager.start()

// And to close application
appManager.close()
```

Let's start by creating `support` directory where I'd put `AppManager.js`,
`bootstrap.js` and `teardown.js` files:

``` shell
$ mkdir support
# And create empty file there
$ touch support/appManager.js support/bootstrap.js support/teardown.js
```

Note that commands are executed from project main directory, not app.

Now it's time for `AppManager` class, start with constructor:

``` js
const defaultConfig = {
  host: 'localhost',
  port: 3000,
  appPath: './vanillajs'
  appCommand: 'yarn run start'
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
multiple places and still get the same object. If I create new instance in
different modules I'd lost track of `_app` property and won't be able to close
it during teardown.

Next thing is to create `start` method. It should accept a callback to execute
it after application is ready to let know Codecept that it can start running
tests. To wait until app is ready I'm using
[`tcp-port-used`](https://www.npmjs.com/package/tcp-port-used) package, so start
by adding it:

``` shell
$ yarn add --dev tcp-port-used
```

And finally implement the `start` method:

``` js
// support/appManager.js
const cp = require('child_process');
const tcpPortUsed = require('tcp-port-used');

class AppManager {
  // ...

  start(callback) {
    console.log(`Starting app at: ${this.host}:${this.port}`);

    // Spawn shell and execute appCommand in appPath directory
    this._app = cp.exec(this.config.appCommand, { cwd: this.config.appPath });

    // Block execution of tests till app is upp
    this._waitForApp(callback);
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

// ...
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
// ...
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
$ yarn add --dev ps-tree
```

Now comes the `close` method of `AppManager` class:

``` js
// support/appManager.js
const psTree = require('ps-tree');

class AppManager {
  // ...
  close() {
    psTree(this._app.pid, (err, children) => {
      cp.spawn('kill', ['-9'].concat(children.map(p => p.PID)))
    });
  }
}
```

Yeah, that's all! `psTree` gets process pid as first parameter, then it calls
callback with two parameters. The second attribute is an array of all children
of our application process, then only thing that's necessary is to spawn `kill`
command with list of pids of child processes.

I'm using `kill -9` here because I don't need to worry about gracefully shutting
down application. However in real-world use case it might be good idea to
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

I'd also use more reasonable directories structure instead of throwing
application code just in the middle of files related with tests.

Thank you for reading!
