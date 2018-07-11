defmodule AssemblageWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation

  object :session do
    field :user, :user
  end

  object :user do
    field :id, :id
    field :name, :string
    field :auth_token, :auth_token
    field :credential, :credential
  end

  object :credential do
    field :email, :string
  end

  object :auth_token do
    field :token, :string
  end
end
