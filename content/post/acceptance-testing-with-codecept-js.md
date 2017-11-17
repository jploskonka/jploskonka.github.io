---
title: Acceptance testing with CodeceptJS
aliases: ['/acceptance-testing-with-codecept-js']
date: 2017-01-13
---

In this tutorial I'm gonna look at CodeceptJS with NightmareJS backend as a tool
for writing acceptance tests for TodoMVC application. After completing it you
should be familiar with basic codecept concepts and be able to use it in your
own projects.

I'm using vanillaJS version of TodoMVC available
[here](http://todomvc.com/examples/vanillajs/) but probably you can use whatever
version you want to—features are supposed to be the same, the only difference
may be in HTML selectors of elements user would interact with (although I
haven't tested it so can't be sure).

## tl;dr
Just check out the code
[here](https://github.com/jploskonka/testing-with-codeceptjs/tree/v2.1.1).

## What is TodoMVC?
[TodoMVC](http://todomvc.com/) is a project created to help developers decide
which JavaScript framework would they want to use in their projects. It shows the
same application—basic todo list—written in bunch of popular (and some not
so popular) JS frameworks so one can compare various tools in the same use case.

## What is CodeceptJS?
[CodeceptJS](http://codecept.io/) is a framework for writing end-to-end tests
for web applications. It abstracts common interaction with pages to simple
methods and can use basically anything that implements [WebDriver
specification](https://www.w3.org/TR/webdriver/) as it's backend. So you're
not tied to Selenium here. It's very well documented so make sure to check out
its website!

I like it especially for simple API and the fact that it's written in pure ES6
supported by node **without transpiler**, so there's no need for additional
dependency like Babel. Thank you [Michael
Bodnarchuk](https://github.com/DavertMik) for that!

## What is NightmareJS?
[NightmareJS](http://www.nightmarejs.org/) is a library for automating
interactions with web pages. Under the covers it uses Electron as a web browser.
However it's also much younger than good ol' Selenium so I'd expect to
encounter some strange issues and edge cases here, but where would be
fun without such problems?

## What is Electron?
[Electron](http://electron.atom.io/) previously known as Atom Shell was
originally created by Github for Atom editor. Then it evolved into platform
for building desktop applications with use of web technologies like HTML and
JavaScript. You can think of it as minimal Chromium browser with JavaScript API
to control it.

## Getting started
### NodeJS and YARN dependencies
Before starting make sure you have [node](https://nodejs.org/en/) and
[yarn](https://yarnpkg.com/) packages installed and updated. I'm using node
`8.9.1` and yarn `1.3.2`. You can check your versions with following commands:

``` shell
$ node -v
$ yarn --version
```

### Setting up testing environment
Let's start by creating new directory:

``` shell
$ mkdir codeceptjs_testing
```

Then initialize yarn project:

``` shell
$ yarn init
```

You'll get prompted to answer for few basic questions to populate `package.json`
file.

``` javascript
// package.json
{
  "name": "acceptance-testing-with-codeceptjs",
  "version": "1.0.0",
  "description": "Sample testing suite created with http://codenroll.it/acceptance-testing-with-codecept-js/ tutorial",
  "repository": "https://github.com/jploskonka/testing-with-codeceptjs",
  "author": "Jakub Ploskonka",
  "license": "MIT"
}
```
You can remove `main` entry from your `package.json`, it's used by npm/yarn to
decide which file should be invoked when the module is required. In this case it
doesn't matter, because I'm not expecting testing suite to be required anywhere.

Now it's time to add CodeceptJS and Nightmare dependencies:

``` shell
$ yarn add --dev codeceptjs nightmare nightmare-upload
# I'm using following versions:
# codeceptjs: 1.0.3
# nightmare: 2.10.0
# nightmare-upload: 0.1.1
```

Finally initialize Codecept environment:

``` shell
$ yarn run codeceptjs init
```

Make sure to select `Nightmare` with your spacebar when asked for which helpers
you wanna use. I'm also using `tests/**/*_test.js` as tests path instead of
default one. You should get output like this:

![codeceptjs_init.jpg](/images/2016-01-13/codeceptjs_init.jpg)

[Codecept's configuration](http://codecept.io/configuration/) is stored in
`codecept.json` file in project root directory.

``` javascript
// codecept.json
{
  "tests": "tests/**/*_test.js",
  "timeout": 10000,
  "output": "./output",
  "helpers": {
    "Nightmare": {
      "url": "http://todomvc.com/examples/vanillajs"
    }
  },
  "include": {},
  "bootstrap": false,
  "mocha": {},
  "name": "my-amazing-testing-suite"
}
```

## Writing first test
Let's start by creating first scenario that would check if adding a new todo works
correctly.

Codecept comes with bunch of handy generators to automate common development
tasks. All files I'm creating in the course of this tutorial are added with
generators, unless stated otherwise. You can create your first test by running:

``` shell
$ yarn run codeceptjs gt
# gt—short for Generate Test
```

Provide name for your test and open newly created file in your favourite JS
editor. I'm using `add_todo_test.js` as filename of test and `Add todo` as
feature I'm testing. Generated file should like this:

``` javascript
// tests/add_todo_test.js
Feature('Add todo');

// Note: I updated parameter here
Scenario('User adds a new todo', (I) => {

});
```

## Good to know
Before we jump into writing code it's a good idea to introduce two small
improvements into our workflow:

### Convenient command to run tests
To run our tests you can use following command:

``` shell
$ yarn run codeceptjs run --steps
```

That's a lot of characters to type in. Instead of that let's add `test` command
to `package.json` file:

``` javascript
// package.json
// ...
"license": "MIT",
"scripts": {
  "test": "codeceptjs run --steps"
},
"devDependencies": {
// ...
```

Now tests can be run by using:

``` shell
$ yarn test
```

### Running only some of tests
When your test suite is getting bigger it's useful to be able to run only few
scenarios. To do that you can use you can use `--grep` option with `codeceptjs
run` command. This'll look for matches in parameters of `Feature` and `Scenario`
methods (**it's case sensitive!**), for example:

``` shell
$ yarn test -- --grep Add
# Note usage of double dashes here to pass flag to codeceptjs binary instead of
yarn
```

### Display browser window for easier debugging

Just add `show: true` option to nightmare config:
``` javascript
// codecept.json
// ...
"Nightmare": {
  "url": "http://todomvc.com/examples/vanillajs",
  "show": true
}
// ...
```

## Back to code—adding a todo
Now that we know how to run our tests and we can easily see what's going on in
browser let's add first scenario! :-)

To create a new todo, user would visit the page, insert content of todo into
`.new-todo` input and press `Enter` key. I'd say todo is created successfully
when its content is visible inside `.todo-list` element. Scoping our
expectations is important here because in case user would forget to save the
task its content would still be visible inside input field and the test would
pass.

``` javascript
// tests/add_todo_test.js
Feature('Add todo');

Scenario('User adds a new todo', (I) => {
  const todoContent = 'Learn testing with CodeceptJS';

  I.amOnPage('/');
  I.fillField('.new-todo', todoContent);
  I.pressKey('Enter');
  I.see(todoContent, '.todo-list');
});
```

Now run tests with:

``` shell
$ yarn test
```

The path passed as argument to `I.amOnPage` method will be merged with url
set in Nightmare configuration in `codecept.json` file.

## Removing a todo
To delete a todo it'd be good to create one first. Then user would click on the
`.destroy` element next to the task and there would be no todo with provided
content inside `.todo-list` if everything works as expected. I'm gonna use CSS
`:nth-child` pseudo selector to find todo at correct position and delete it. For
now I'm testing with only one task on list so it doesn't make big difference
because Codecept would click on first matching element anyway, but will be
necessary soon.

``` javascript
// tests/remove_todo_test.js
Feature('Remove todo');

Scenario('User removes todo', (I) => {
  const todoContent = 'Learn testing with CodeceptJS';

  I.amOnPage('/');
  I.fillField('.new-todo', todoContent);
  I.pressKey('Enter');
  I.click('.todo-list > li:nth-child(1) .destroy');
  I.dontSee(todoContent, '.todo-list');
});
```

`I.click` method accepts context to narrow search of elements as second
argument, however either I can't use it correctly or it's ignored currently.
Anyway I couldn't force it to work that's why I'm not using it :-(

## Refactoring with [page objects](http://codecept.io/pageobjects/)
OK, so tests works as expected but they're starting to look ugly as hell.
There's a lot of HTML selectors scattered here and there and too much of
implementation details are exposed in scenarios code. What if I change form to
create a new task so instead of pressing `Enter` user needs to click on a button
to add a todo? Or for some unknown reason I decide that `.todo-list` is bad name
and I want to name it `.task-list`? I'd have to look through my entire code and
update all those little places. Sounds like huge pain in the ass :-(

Luckily there's a pattern called [Page
Object](https://martinfowler.com/bliki/PageObject.html) which exist to solve
exactly this kind of problems. And what's even more awesome Codecept provides
great support for it!

Start with a `page object` generator:

``` shell
$ yarn run codeceptjs gpo
```

Let's name it `TodoList` and place it at `pages/TodoList.js` (as generator would
suggest). As last step I'm gonna change naming of this object in `codecept.json`
file from this:

``` javascript
"include": {
  "todoListPage": "./pages/TodoList.js"
},
```

into this:

``` javascript
"include": {
  "TodoList": "./pages/TodoList.js"
},
```

I like page object names to start with capital letter and I think the `Page`
suffix doesn't help in any way so there's no need for additional 4 keystrokes.

Now it's time to extract methods for adding and removing tasks:

``` javascript
// pages/TodoList.js
'use strict';

let I;

module.exports = {

  _init() {
    I = actor();
  },

  // Element getters
  newFormEl: () => '.new-todo',
  listEl: () => '.todo-list',

  todoEl(position) {
    return `.todo-list > li:nth-child(${position})`;
  },

  todoDestroyEl(position) {
    return `${this.todoEl(position)} .destroy`;
  },

  // Interactions
  add(content) {
    I.fillField(this.newFormEl(), content);
    I.pressKey('Enter');
  },

  remove(position) {
   I.click(this.todoDestroyEl(position));
  }
}
```

Inside page objects it's good to follow some kind of a convention to keep them
similar, in this case I'm putting methods to get HTML selectors first,
suffixing them with `El`. Then I have methods responsible for actual
interactions with page.

Last thing to take care of in order to use page objects inside scenarios is to
add it's name (same as defined in `codecept.json` file) to list of arguments
passed to test like this:

``` javascript
Scenario('message', (I, TodoList) => {...})
```

Finally here're test files using `TodoList` object:

``` javascript
// tests/add_todo_test.js
Scenario('User adds a new todo', (I, TodoList) => {
  const todoContent = 'Learn testing with CodeceptJS';

  I.amOnPage('/');
  TodoList.add(todoContent);
  I.see(todoContent, TodoList.listEl());
});
```

``` javascript
// tests/remove_todo_test.js
Scenario('User removes todo', (I, TodoList) => {
  const todoContent = 'Learn testing with CodeceptJS';

  I.amOnPage('/');
  TodoList.add(todoContent);
  TodoList.remove(1);
  I.dontSee(todoContent, TodoList.listEl());
});
```

## Riddle time
There's one issue with those 2 scenarios: first of them can pass even if adding
task is broken and second can fail when removing feature works correctly.
What's the issue?

## Editing a todo
Same as with removing todo it'd be good idea to create todo before editing it.
Then user would double click on existing todo leading to show him or her input
to enter new content. Now it's only a matter of pressing Enter key and checking
if task at specified position has updated content.

Let's start with `edit` method for `TodoList` page:

``` javascript
// pages/TodoList.js
// ...

todoContentEl(position) {
  return `${this.todoEl(position)} label`;
},

todoEditEl(position) {
  // There's no need to scope to todo position here because
  // it's possible to have only one todo in editing state
  return `${this.listEl()} .edit`
},

// ...

edit(position, newContent) {
  I.doubleClick(this.todoContentEl(position));

  I.fillField(this.todoEditEl(position), newContent);
  I.pressKey('Enter');
}
```

And test itself:

``` javascript
// tests/edit_todo_test.js
Feature('Edit todo');

Scenario('User edits todo', (I, TodoList) => {
  const oldContent = 'Learn testing with CodeceptJS';
  const newContent = 'Listen to the music'
  const context    = TodoList.todoEl(1);

  I.amOnPage('/');
  TodoList.add(oldContent);
  TodoList.edit(1, newContent);

  I.dontSee(oldContent, context);
  I.see(newContent, context);
});
```

## Is it done?
Quite important feature for every todo list application is ability to check
what's already done and what is still to do. To expect checkbox to be in checked
state (so when the todo is completed) Codecept provides `seeCheckboxIsChecked`
method. With this knowledge there should be no problem at all to test if this
feature works as expected.

Let's start by adding `toggle` method to `TodoList`:

``` javascript
// pages/TodoList.js
// ...
todoToggleEl(position) {
  return `${this.todoEl(position)} .toggle`;
},

// ...

toggle(position) {
  I.click(this.todoToggleEl(position));
}
```

And test file itself:

``` javascript
// tests/state_togglers_test.js
Feature('State togglers')

const todoContent = 'Learn testing with CodeceptJS';

Before((I, TodoList) => {
  I.amOnPage('/');
  TodoList.add(todoContent);
});

Scenario('User marks todo as done', (I, TodoList) => {
  TodoList.toggle(1);
  I.seeCheckboxIsChecked(TodoList.todoToggleEl(1));
});

Scenario('User marks todo as undone', (I, TodoList) => {
  // This .toggle call is part of scenario setup,
  // because added todo is incompleted by default
  TodoList.toggle(1);

  // And now the actual interaction which we want to test
  TodoList.toggle(1);
  I.dontSeeCheckboxIsChecked(TodoList.todoToggleEl(1));
});
```

The second scenario is not perfect because if the `.toggle` method doesn't work
(it may be broken feature, it may be broken method itself) it's still gonna
pass, but in that case the first scenario would fail.

## Before/After hooks
To help with repeating tasks like preparing application before scenarios
Codecept uses `Before` and `After` [hooks](http://codecept.io/basics/#before)
where you can place code needed to be executed before or after every scenario
(like creating todo in this case).

It may be tempting to move first `toggle` call also to `Before` hook, but
personally I don't like this idea because in case of first Scenario it's not
part of preparation to test but actual interaction user would do. You may do as
you prefer, however tests should be easy to understand and read even if it
forces some code duplication. In this case test file is so small that it
probably won't make much difference.

## Would you remember me?
So now it's finally time to have some fun and test if our todos are actually
stored in browser's local storage ([check out great article about
it](https://www.smashingmagazine.com/2010/10/local-storage-and-how-to-use-it/)).
The simplest way to achieve is to refresh the page after interacting
with it and check if changes are still visible.

It's important to note here that todos are loaded AFTER page loads, so it's not
enough to just refresh page and duplicate our expectations (like `I.see(...)`).
This way specs would fail because tasks still won't be loaded when expectations
are called. Instead we have to use `I.waitForText` and `I.waitForElement`
methods to wait until tasks are fetched. By default Codecept will wait for 1
second and if there's no matching text or element test will fail. You can
override it by passing second argument to `I.waitForXXX` methods.

The third argument is element in which expected text or element should be. In
case of using it it's necessary to also pass timeout as second one.

Let's start by updating our current scenarios:

``` javascript
// tests/add_todo_test.js
// ...
I.see(todoContent, TodoList.listEl());

I.refresh();
I.waitForText(todoContent, 1, TodoList.listEl());
```

``` javascript
// tests/edit_todo_test.js
// ...
I.see(newContent, context);

I.refresh();
I.waitForText(newContent, 1, context);
```

``` javascript
// tests/remove_todo_test.js
// ...
I.dontSee(todoContent, TodoList.listEl());

I.refresh();
I.dontSee(todoContent, TodoList.listEl());
```

``` javascript
// tests/state_togglers_test.js
Scenario('User marks todo as done', (I, TodoList) => {
  // ...
  I.seeCheckboxIsChecked(TodoList.todoToggleEl(1));

  I.refresh();
  // Wait for todo to be loaded
  I.waitForElement(TodoList.todoEl(1));
  // Check toggler
  I.seeCheckboxIsChecked(TodoList.todoToggleEl(1));
});

Scenario('User marks todo as undone', (I, TodoList) => {
  // ...
  I.dontSeeCheckboxIsChecked(TodoList.todoToggleEl(1));

  I.refresh();
  // Wait for todo to be loaded
  I.waitForElement(TodoList.todoEl(1));
  // Check toggler
  I.dontSeeCheckboxIsChecked(TodoList.todoToggleEl(1));
});
```

## Preparing todos before testing
It doesn't feel good to manually create task before testing actions like edit
or remove. Wouldn't it be nice if application started with bunch of todos
already created, waiting there for tester to just play with them? Yeah, it
would. Luckily it's quite easy to achieve.

TodoMVC uses local storage to save data and loads them on next user visits from
same browser. We can use this fact in our favor and fill it with some tasks
before running scenario. Let's start by checking out what is the format of data
by using Chrome Developer Tools.

If you're not familiar with local storage please see
[this](https://www.smashingmagazine.com/2010/10/local-storage-and-how-to-use-it/)
or [that](https://developer.mozilla.org/en/docs/Web/API/Window/localStorage) or
maybe even [W3C spec](https://www.w3.org/TR/webstorage/). Yes, you should
definitely check out specs—it's an awesome reading!

Open
[http://todomvc.com/examples/vanillajs/](http://todomvc.com/examples/vanillajs/)
with Chrome Browser, add some todos to it then open Developer Tools with `Ctrl +
Shift + I` (or `CMD + Opt + I` if you're using Mac OS) and select `Application`
tab. In left column select `Local Storage` and `http://todomvc.com` domain.

![dev_tools](/images/2016-01-13/dev_tools.jpg)

You can see there's entry with key `todos-vanillajs` and value like this (I'm
using [http://jsonviewer.stack.hu/](http://jsonviewer.stack.hu/) to see JSON in
nice format):

``` javascript
{
  "todos": [
    {
      "title": "Learn codeceptJS",
      "completed": false,
      "id": 1483639709956
    },
    {
      "title": "Listen to the music",
      "completed": true,
      "id": 1483639712979
    },
    {
      "title": "Party party party!",
      "completed": false,
      "id": 1483639723603
    }
  ]
}
```

It turns out to be pretty simple JSON, that's awesome!
Now I'm gonna use Codecept's `executeScript` method and `Before` hook to
populate local storage with tasks json. If everything goes well I shall have
some tasks to play with in scenarios. To keep things nice and clean I'll create
`EnvironmentManager` helper and keep code related to it there.

[Helpers](http://codecept.io/helpers/) are ES6 classes inherited from `Helper`
abstract class. All methods defined in helper class will be available on `I`
object inside scenarios.  Helpers can also define hooks like `_before` or
`_after` (note little bit different syntax then hooks in scenarios). Full list
is available [here](http://codecept.io/helpers/#hooks).

I'll also move `I.amOnPage('/')` line from all test files to this helper making
it one and only class responsible for preparation of environment before scenarios.

Last but not least I'm gonna create `fixtures` directory to avoid unnecessary
clutter in helper code and store tasks JSON there.

Let's start with helper generator:

``` shell
$ yarn run codeceptjs gh
# gh—short for Generate Helper
```

I'm gonna name it `EnvironmentManager` and use place it at
`helpers/environment_manager_helper.js`

``` javascript
'use strict';

// Local storage can handle only strings as keys or values
// thus usage of JSON.stringify on required fixture.
const TODOS = JSON.stringify(require('../fixtures/todos.json'));

// Don't use magic strings like `todos-vanillajs` across code,
// instead store it in constant with self-explaining name.
const STORAGE_KEY = 'todos-vanillajs';

// Note this function is not part of helper.
// It shouldn't be available for outside world so keep it outside
// of exported class.
function setTodos(todos, storageKey) {
  // Clear local storage before saving to it
  localStorage.clear();

  // Save todos in local storage
  localStorage.setItem(storageKey, todos);
}

class EnvironmentManager extends Helper {
  _before() {
    this.helpers['Nightmare'].amOnPage('/');
    // console.log('before')
    // Access Nightmare helper
    // There's no semicolon at the end of this line!
    this.helpers['Nightmare']

      // execute `setTodos` function in browser and pass
      // TODOS and STORAGE_KEY parameters to it
      .executeScript(setTodos, TODOS, STORAGE_KEY);

    // This one is important!
    // `executeScript` runs in browser context. To be able to do
    // that there needs to be page opened.
    // Because of it we can't populate local storage before opening
    // page but TodoMVC loads content on page load. So I have to refresh
    // my page after filling up local storage.
    return this.helpers['Nightmare'].refresh();
  }
}

module.exports = EnvironmentManager;
```

And the fixture is just a plain JSON file:

``` javascript
// fixtures/todos.json
{
  "todos": [
    {
      "title": "Learn codeceptJS",
      "completed": false,
      "id": 1483639709956
    },
    {
      "title": "Listen to the music",
      "completed": true,
      "id": 1483639712979
    },
    {
      "title": "Party party party!",
      "completed": false,
      "id": 1483639723603
    }
  ]
}
```

`Fixtures` concept is not part of Codecept's features so this file is created
manually without use of generator.

Uff, that was fun! Of course if you run tests right now (yup, you **should** try it)
everything will blow up straight in your face. It means our code actually is
executed and does *something*! :D

Let's finally make those tests green by removing redundant `I.amOnPage('/')`
calls and using existing tasks for edit, remove and state togglers tests instead
of creating new ones.

``` javascript
// tests/add_todo_test.js
Scenario('User adds a new todo', (I, TodoList) => {
  const todoContent = 'Learn testing with CodeceptJS';

  TodoList.add(todoContent);
  I.see(todoContent, TodoList.listEl());
  // ...
```

``` javascript
// tests/edit_todo_test.js
Feature('Edit todo');

const TODOS = require('../fixtures/todos.js');

Scenario('User edits todo', (I, TodoList) => {
  const oldContent = TODOS[0].title;
  const newContent = 'Todo content after edit';
  const context    = TodoList.todoEl(1);

  TodoList.edit(1, newContent);
  // ...
```

``` javascript
// tests/remove_todo_test.js
Feature('Remove todo');

const TODOS = require('../fixture/todos.js');

Scenario('User removes todo', (I, TodoList) => {
  const todoContent = TODOS[0].title;

  TodoList.remove(1);
  // ...
```

``` javascript
// tests/state_togglers_test.js
Feature('State togglers')

const TODOS = require('../fixtures/todos.js').todos;

// Yay, no need for Before hook here,

// first scenario doesn't require any changes.

Scenario('User marks todo as undone', (I, TodoList) => {
  const todoPosition = 2;

  TodoList.toggle(todoPosition);
  I.dontSeeCheckboxIsChecked(TodoList.todoToggleEl(todoPosition));

  I.refresh();
  // Wait for todo to be loaded
  I.waitForElement(TodoList.todoEl(todoPosition));
  // Check toggler
  I.dontSeeCheckboxIsChecked(TodoList.todoToggleEl(todoPosition));
});
```

## Solve the riddle!
When I was testing adding and removing tasks I was basing on list with only one
of them. Because of that I let myself to ignore two cases:
- Adding todo scenario would of course pass if there's already a task with the
  same content as one added by user.
- Removing todo scenario would fail if there's more than one task with the same
  content as one removed by user.

To fix those issues I'm gonna check the number of tasks present on list before
creating or removing one, assign it to some variable and then compare it with
new count of tasks expecting it to increase or decrease properly. In case of
creating a new item I'm also gonna verify the content of **last** task.

``` javascript
// pages/TodoList.js

// Element getters
//...

// Update this to handle both universal selector for todo
// and one at specified position
todoEl(position) {
  let el = '.todo-list > li';

  if(position)
    el = [el, `:nth-child(${position})`].join('');

  return el;
},
// ...

// Content getters
// I'm using yield to pass result from script executed in browser
// into scenario. It can be used only inside generator.
getTodoCount: function* () {
  return yield I.executeScript(el => {
    // Find all todos and get length of resulting array
    return document.querySelectorAll(el).length;
  }, this.todoEl());
},

// Interactions
// ...
```

``` javascript
// tests/add_todo_test.js
const assert = require('assert');

Feature('Add todo');

// Note usage of generator instead of arrow function
Scenario('User adds a new todo', function* (I, TodoList) {
  const todoContent = 'Learn testing with CodeceptJS';
  const todoCount = yield* TodoList.getTodoCount();

  TodoList.add(todoContent);

  const newTodoCount = yield* TodoList.getTodoCount();
  const lastTodo = TodoList.todoEl(newTodoCount);

  // Check if there's one more task on list
  assert.equal(newTodoCount, todoCount + 1);

  I.see(todoContent, lastTodo);

  I.refresh();
  I.waitForText(todoContent, 1, lastTodo);
});
```

``` javascript
// tests/remove_todo_test.js
const assert = require('assert');

Feature('Remove todo');

const TODOS = require('../fixtures/todos.json').todos;

// Note usage of generator instead of arrow function
Scenario('User removes todo', function* (I, TodoList) {
  const todoContent = TODOS[0].title;
  const todoCount = yield* TodoList.getTodoCount();

  TodoList.remove(1);

  const newTodoCount = yield* TodoList.getTodoCount();
  assert.equal(newTodoCount, todoCount - 1);

  I.dontSee(todoContent, TodoList.listEl());

  I.refresh();
  I.dontSee(todoContent, TodoList.listEl());
});
```

In order to get result of script executed in browser context into scenario
context I use ES6 generator functions. If you're not familiar with them
[here's](https://medium.com/@dtothefp/why-can-t-anyone-write-a-simple-es6-generators-tutorial-ec2bbdf6ff45#.h918s0un9)
great tutorial about it. I also use [`yield*`
expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/yield*)
to delegate execution from one generator (scenario) to another
(`TodoList.getTodoCount` method).

## Filtering tasks
Last thing left to test is ability to select only completed or uncompleted
tasks. This should be pretty straightforward with what you already know. To test
those I'm gonna just click on filter and then compare existing tasks with those
from fixture expecting only correct ones to be present on list.

To avoid duplicating code responsible for checking if todos are visible on list
I start with adding `hasTodos` and `hasNoTodos` methods to `TodoList` object:

``` javascript
// pages/TodoList.js

// ...

// Expectations
hasTodos(todos) {
  todos.forEach(t => I.see(t.title, this.listEl()));
},

hasNoTodos(todos) {
  todos.forEach(t => I.dontSee(t.title, this.listEl()));
}
```

Nothing fancy here, just iterate over array of todos and check if user see or
doesn't see them on list.

Now methods to interact with filters:
``` javascript
// pages/TodoList.js
  // ...

  // Element getters
  activeFilterEl: () => '.filters li:nth-child(2) a',
  completedFilterEl: () => '.filters li:nth-child(3) a',

  // ...

  // Interactions
  selectCompleted() {
    I.click(this.completedFilterEl());
  },

  selectActive() {
    I.click(this.activeFilterEl());
  },

  // ...
```

Finally I'm creating new file for filters tests (still remember about test
generator?):

``` javascript
// tests/filters_test.js

Feature('Filters');

const TODOS           = require('../fixtures/todos.js').todos;
const TODOS_ACTIVE    = TODOS.filter(t => !t.completed);
const TODOS_COMPLETED = TODOS.filter(t => t.completed);

Scenario('User does not apply any filter', (I, TodoList) => {
  TodoList.hasTodos(TODOS);
});

Scenario('User selects only active tasks', (I, TodoList) => {
  TodoList.selectActive();

  TodoList.hasTodos(TODOS_ACTIVE);
  TodoList.doesntHaveTodos(TODOS_COMPLETED);
});

Scenario('User selects only completed tasks', (I, TodoList) => {
  TodoList.selectCompleted();

  TodoList.hasTodos(TODOS_COMPLETED);
  TodoList.doesntHaveTodos(TODOS_ACTIVE);
});
```

Simple!

## And... That's it!
That was fun! Most of functionalities are covered and code looks pretty good.
I'm not huge fan of how page objects are implemented though—I like the idea of
starting interactions with page with `I` object, because it's just good to read,
but page objects somehow breaks this nice flow for me. `I` am adding todos to
page, `I` am editing those. On the other hand keeping all methods on `I` object
would be perfect example of using [God
Object](https://en.wikipedia.org/wiki/God_object) so I'm not totally sure what's
the best direction here.

There're still some features of Codecept that I didn't covered like [Page
Fragments](http://codecept.io/pageobjects/#page-fragments), [Step
Objects](http://codecept.io/pageobjects/#stepobjects) or custom steps, but I
believe current codebase is good enough so there's no point in further
refactoring of it. Once again—make sure to check out [codecept
docs](http://codecept.io/)!

With all those issues in mind I still think that Codecept is one of the best and
definitely one of most (if not the most) pleasant JS testing tool available
right now. Big thanks to [Michael](https://github.com/DavertMik) for maintaining
it and to you for going through this tutorial!

You can grab code from
[here](https://github.com/jploskonka/testing-with-codeceptjs/tree/v2.1.1).

## What's next?
If you want to play little bit more with this I'd start with rethinking
`TodoList` page object—few more methods and it'll be too big in my opinion.
Maybe extract single todo interactions to some Page Fragment? I'd also love to
see some experiments with moving from Nightmare to Selenium—how much work is
actually necessary to swap drivers, how much faster is Nightmare etc. I'd also
think about cleaning up add/remove todo tests somehow, because it feels there's
a bit too much code there.

Thank you for reading and be sure to leave me some feedback in comments.

## Changelog
- 2017-11-07: Updated content to match codeceptJS version 1.0.3 (was 0.4.13)

