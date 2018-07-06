defmodule AssemblageWeb.Router do
  use AssemblageWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AssemblageWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug AssemblageWeb.Context
  end

  scope "/api" do
    pipe_through :api

    forward("/test", Absinthe.Plug, schema: AssemblageWeb.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: AssemblageWeb.Schema)
  end

  scope "/", AssemblageWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/session", SessionController, only: [:new, :create, :delete]
  end

  scope "/manage", AssemblageWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/images", ImageController
  end
end
