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

  alias Assemblage.Accounts.{Authenticator, AuthToken, User}

  @doc """
  Registers (creates) a user
  """
  @spec register_user(map()) :: {:ok, User.t()} | {:error, String.t()}
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update info held on the User struct itself, for example
  the name field.
  """
  @spec update_user_info(User.t(), map()) :: {:ok, User.t()} | {:error, String.t()}
  def update_user_info(user, params) do
    if Map.has_key?(params, :credential) do
      # Note that any attempt to update credentials via this function
      # would fail silently anyway, as the association is not loaded in any case
      {:error, "Attempt made to update credentials without validating"}
    else
      user
      |> User.changeset(params)
      |> Repo.update()
    end
  end

  @doc """
  Given a user, update the email held on the associated
  Credential struct. To do so, a password must be given.
  """
  @spec update_user_email(User.t(), String.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def update_user_email(user, new_email, password) do
    with {:ok, user} <- check_password(user, password) do
      user
      |> User.update_changeset(%{credential: %{email: new_email}})
      |> Repo.update()
    end
  end

  @doc """
  Given a user, update the password held on the associated
  Credential struct. To do so, the current password must be given.
  """
  @spec update_user_password(User.t(), String.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def update_user_password(user, new_password, current_password) do
    with {:ok, user} <- check_password(user, current_password) do
      user
      |> User.update_changeset(%{credential: %{password: new_password}})
      |> Repo.update()
    end
  end

  @doc """
  TODO
  1. deleting a user should set a deleted flag on their struct to true.
  2. the password should be cleared and the email hashed.
  3. This means that there should be a revive user function
  4. in the case that that is called, the email should be decoded and a
     notification should be sent to force a password reset.
  5. this is quite complex: a notification system needs to be in place first.
  """
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, String.t()}
  def delete_user(user) do
    Repo.delete(user)
  end

  @doc """
  Get a User based on the email stored in their linked credentials.

  FIXME spec is incorrect: Need to return correct error tuples if the lookup fails
  """
  # @spec get_user_by_email(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user_by_email(email) do
    # FIXME deal with lookup failing, will just get `nil` as things stand
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
    |> Repo.one()
    |> Repo.preload(:credential)
  end

  @doc """
  Get a User based on their auth token.

  FIXME spec is incorrect: Need to return correct error tuples if the lookup fails
  """
  # @spec get_user_by_token(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user_by_token(token) do
    case Authenticator.verify_token(token) do
      {:ok, _} ->
        # FIXME deal with lookup failing, will just get `nil` as things stand
        from(u in User, join: c in assoc(u, :auth_token), where: c.token == ^token)
        |> Repo.one()
        |> Repo.preload(:auth_token)

      {:error, reason} ->
        # FIXME just stringify the reason for now
        {:error, to_string(reason)}
    end
  end


  @doc """
  TODO return a _User_ struct with the association loaded, not an AuthToken
  struct. It is easier overall if these functions always return a user.
  """
  def sign_in(email, password) do
    with user <- get_user_by_email(email),
         {:ok, user} <- check_password(user, password) do
      token = Authenticator.generate_token(user.id)

      user
      |> Ecto.build_assoc(:auth_token, %{token: token})
      |> Repo.insert()
    end
  end

  @doc """
  TODO as above
  TODO this is `authorized?`, not `signed_in?`. `signed_in` is not really a
  valid concept (semantically) in this case, once a user has a token, then
  that's the only thing they need.
  """
  @spec signed_in?(User.t()) :: boolean()
  def signed_in?(user) do
    token_assoc = user |> Ecto.assoc(:auth_token) |> Repo.one()

    case token_assoc do
      %{token: nil} -> false
      %{revoked: true} -> false
      %{token: _token} -> true
      _ -> false
    end
  end

  @doc """
  TODO this is deletion of a token, not strictly speaking signing out. It will
  work as a signing out mechanism just fine, but need to
      a. be a bit more consistent w/r/t return values,
      b. look at updating via the user (assoc with AuthToken) - currently this will
        just blow away the AuthToken struct without any reference to the User it belongs to.
  """
  @spec sign_out(String.t()) :: {:ok, AuthToken.t()} | {:error, String.t()}
  def sign_out(token) do
    AuthToken
    |> Repo.get_by(%{token: token})
    |> Repo.delete()
  end

  @spec check_password(User.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def check_password(%User{credential: %{password_hash: password_hash}} = user, password) do
    # Because the credentials are not stored directly ono the User, Comeonin's handy
    # `check_pass` function, which does exactly the following, will not work
    case Comeonin.Bcrypt.checkpw(password, password_hash) do
      true -> { :ok, user }
      false -> { :error, "Authentication failed for operation" }
    end
  end
end
