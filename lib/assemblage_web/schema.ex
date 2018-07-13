defmodule AssemblageWeb.Schema do
  use Absinthe.Schema

  alias AssemblageWeb.Resolvers
  alias AssemblageWeb.Schema.Middleware

  import_types __MODULE__.AccountsTypes

  mutation do
    @desc "Register a user if they provide a valid name, email and password, then log them in."
    field :register, :session do
      arg :name, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.register/3
      middleware Middleware.ChangesetErrors
      # GraphQL is stateful, and and changes made to the context persist.
      # On register, add the user to the context.
      middleware fn res, _ ->
        with %{value: %{current_user: current_user}} <- res do
          %{res | context: Map.put(res.context, :current_user, current_user)}
        end
      end
    end

    @desc "Allow a user to log in using their email and password."
    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &Resolvers.Accounts.sign_in/3
      middleware Middleware.ChangesetErrors
      # GraphQL is stateful, and and changes made to the context persist.
      # On login, add the user to the context.
      middleware fn res, _ ->
        with %{value: %{current_user: current_user}} <- res do
          %{res | context: Map.put(res.context, :current_user, current_user)}
        end
      end
    end

    # FIXME NO WORKEE
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
    field :current_users, list_of(:current_user) do
      resolve &Resolvers.Accounts.list_users/3
    end
  end
end
