# Gameserver

## Pre-setup notes for context

Phoenix 1.4 is only at rc stage, so cannot be installed following the instructions in the book - that will install the current 1.3 stable version. Delete the previously installed `phx_new` archive using `mix archive.uninstall phx_new`, then add the 1.4 archive like:

```
mix archive.install https://github.com/phoenixframework/archives/raw/master/1.4-dev/phx_new.ez
```

`mix phx.new` should now work as normal, but create a 1.4 project.

## Running this project

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:5000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).
