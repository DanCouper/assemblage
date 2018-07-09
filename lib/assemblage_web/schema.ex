defmodule AssemblageWeb.Schema do
  use Absinthe.Schema

  alias Assemblage.Repo
  alias Assemblage.Multimedia
  alias AssemblageWeb.Resolvers
  alias AssemblageWeb.Schema.Middleware

  import_types AssemblageWeb.Schema.{AccountsTypes, MultimediaTypes}

  mutation do
    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.login/3
    end

    field :logout, :boolean do
      middleware(Middleware.Auth)
      resolve &Resolvers.Accounts.logout/3
    end
  end

  query do
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
