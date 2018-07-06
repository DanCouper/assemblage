defmodule AssemblageWeb.Schema.AccountsTypes do
  use Absinthe.Schema.Notation

  object :session do
    field :token, :string
    field :user, :user
  end

  object :user do
    field :username, :string
    field :credential, :credential
  end

  object :credential do
    field :email, :string
  end
end
