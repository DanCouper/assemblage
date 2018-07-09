defmodule Assemblage.Accounts do
  @moduledoc """
  The Accounts context.

  Accounts belong to users, and all the functionality exposed deals
  with adding, creating, updating, deleitng and authenticating users.

  Each user has credentials: deleting the credentials will delete that
  user as well, and vise versa.

  Each user has an auth token (with associated information). These are
  transient (albeit long-lived), and the token is used for authorisation.
  The decision has been made to store these server-side for simplicity more
  than anything else; they can be tested in the isolation of the Accounts
  context.

  REVIEW: can I move them from the database to a genserver? There seems no
  need to store them on disk (plus in-memory will be faster). If the genserver
  falls over, then a user just re-authenticates.

  NOTE there are a set of functions that will have to go in the web application,
  related to extracting and adding the token to the conn struct, and in turn to
  the context so that GQL can access it. Basically, need to look in the
  authorization header for the bearer token, and make use of that. At this side,
  just explicitly pass the token.
  """

  import Ecto.Query, warn: false
  alias Assemblage.Repo

  alias Assemblage.Accounts.{User, Authenticator, AuthToken}

  @doc """
  Registers (creates) a user
  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get a User based on the email stored in their linked credentials.
  """
  def get_user_by_email(email) do
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
    |> Repo.one()
    |> Repo.preload(:credential)
  end


  def sign_in(email, password) do
    with user <- get_user_by_email(email),
         {:ok, user} <- Comeonin.Bcrypt.check_pass(user, password) do
      token = Authenticator.generate_token(user.id)

      user
      |> Ecto.build_assoc(:auth_tokens, %{token: token})
      |> Repo.insert()
    end
  end

  def sign_out(token) do
    AuthToken
    |> Repo.get_by(%{token: token})
    |> Repo.delete()
  end
end
