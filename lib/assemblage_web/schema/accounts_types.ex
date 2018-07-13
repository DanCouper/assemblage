defmodule AssemblageWeb.Schema.AccountsTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "Any information held in a user's session, eg important info about the user themselves."
  object :session do
    field :current_user, :current_user
  end

  @desc "The current user, exposing information relevant to their current session."
  object :current_user do
    field :id, :id
    @desc "The current user's chosen name"
    field :name, :string
    field :auth_token, :auth_token
    # field :credential, :credential
  end

  # FIXME credentials should only be exposed in certain cases,
  # and there needs to be role-based auth before this can be
  # incorporated.
  # object :credential do
  #   field :email, :string
  # end

  @desc "The current user's auth token + auth token status"
  object :auth_token do
    @desc "The auth token itself."
    field :token, :string
    @desc "Whether the auth token is revoked or not."
    field :revoked, :boolean
  end
end
