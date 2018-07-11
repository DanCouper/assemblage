defmodule AssemblageWeb.Schema do
  use Absinthe.Schema

  alias AssemblageWeb.Resolvers
  alias AssemblageWeb.Schema.Middleware

  import_types __MODULE__.AccountsTypes

  mutation do
    field :register, :session do
      arg :name, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.register/3
      middleware Middleware.ChangesetErrors
    end

    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.sign_in/3
      middleware Middleware.ChangesetErrors
    end
  end

  query do
    field :users, list_of(:user) do
      resolve &Resolvers.Accounts.list_users/3
    end
  end
end
