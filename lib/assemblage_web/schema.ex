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
      # GraphQL is stateful, and and changes made to the context persist.
      # Need to, on login, add the user to the context.
      # FIXME need to ensure that only fields I want  exposed are exposed:
      # currently, for ease of testing, it's everything.
      middleware fn res, _ ->
        with %{value: %{user: user}} <- res do
          %{res | context: Map.put(res.context, :current_user, user)}
        end
      end
    end

    field :logout, :session do
      resolve &Resolvers.Accounts.sign_out/3
      middleware fn res, _ ->
        with %{context: context} <- res do
          %{res | context: Map.delete(context, :current_user)}
        end
      end
    end
  end

  query do
    field :users, list_of(:user) do
      resolve &Resolvers.Accounts.list_users/3
    end
  end
end
