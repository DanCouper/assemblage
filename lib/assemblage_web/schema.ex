defmodule AssemblageWeb.Schema do
  use Absinthe.Schema

  alias Assemblage.Repo
  alias Assemblage.Multimedia
  alias AssemblageWeb.Resolvers

  import_types AssemblageWeb.Schema.{AccountsTypes, MultimediaTypes}

  mutation do
    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.login/3
    end
  end

  query do
    @desc "The scope that a user can access - anything that lives in this scope uses `:me` as the gatekeeper."
    field :me, :user do
      middleware Middleware.Authorize, :any
      resolve &Resolvers.Accounts.me/3
    end

    @desc "All available images"
    field :images, list_of(:image)  do
      resolve fn _, _, _ ->
        {:ok, Multimedia.list_images()}
      end
    end

    @desc "All available multimedia collections"
    field :collections, list_of(:collection) do
      resolve fn _, _, _ ->
        {:ok, Multimedia.Collection |> Repo.all()}
      end
    end
  end
end
