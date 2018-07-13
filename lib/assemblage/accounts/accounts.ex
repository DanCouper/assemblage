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
  IMPORTANT this is for testing purposes **only**: I need at least one query
  built in so I can check my absinthe logic.
  """
  @spec list_users :: [User.t()]
  def list_users do
    User
    |> Repo.all()
    |> Repo.preload([:auth_token, :credential])
  end

  @doc """
  Registers (creates) a user. Accepts a map of the required information. Note
  that defaults of `nil` are used to ensure that registration failures
  generate nice changeset errors, rather than having the function explode immediately.

  FIXME authorise a user as soon as they have registered
  """
  @spec register(%{name: String.t(), email: String.t(), password: String.t()}) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(registration_attrs) do
    defaults = %{name: nil, email: nil, password: nil}
    %{name: name, email: email, password: password} = Map.merge(defaults, registration_attrs)

    %User{}
    |> User.registration_changeset(%{name: name, credential: %{email: email, password: password}})
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
  @spec update_user_email(User.t(), String.t(), String.t()) ::
          {:ok, User.t()} | {:error, String.t()}
  def update_user_email(user, new_email, password) do
    with {:ok, user} <- check_password(user, password) do
      user
      |> User.credential_changeset(%{credential: %{email: new_email}})
      |> Repo.update()
    end
  end

  @doc """
  Given a user, update the password held on the associated
  Credential struct. To do so, the current password must be given.
  """
  @spec update_user_password(User.t(), String.t(), String.t()) ::
          {:ok, User.t()} | {:error, String.t()}
  def update_user_password(user, new_password, current_password) do
    with {:ok, user} <- check_password(user, current_password) do
      user
      |> User.credential_changeset(%{credential: %{password: new_password}})
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
  """
  @spec get_user_by_email(String.t()) :: nil | User.t()
  def get_user_by_email(email) do
    email
    |> User.by_email()
    |> Repo.one()
    |> Repo.preload([:credential, :auth_token])
  end

  @doc """
  If a user gives a valid email & password, sign them in by generating an
  an auth token and saving it on the assiociated struct.
  """
  @spec sign_in(String.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def sign_in(email, password) do
    with user <- get_user_by_email(email),
         {:ok, user} <- check_password(user, password) do
      token = Authenticator.generate_token(user.id)

      user
      |> User.token_changeset(%{auth_token: %{token: token}})
      |> Repo.update()
    end
  end

  @doc """
  Different from signing in: given a token, verifies it and grabs the
  associated user.
  """
  def verify(token) do
    with {:ok, id} <- Authenticator.verify_token(token) do
      user =
        User
        |> Repo.get(id)
        |> Repo.preload([auth_token: [:token, :revoked], credential: [:email]])

      {:ok, user}
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
  @spec sign_out(User.t()) :: {:ok, AuthToken.t()} | {:error, String.t()}
  def sign_out(user) do
    AuthToken
    |> Repo.get_by(%{user_id: user.id})
    |> Repo.delete()
  end

  @spec check_password(User.t(), String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def check_password(%User{credential: %{password_hash: password_hash}} = user, password) do
    # Because the credentials are not stored directly ono the User, Comeonin's handy
    # `check_pass` function, which does exactly the following, will not work
    case Comeonin.Bcrypt.checkpw(password, password_hash) do
      true -> {:ok, user}
      false -> {:error, "Authentication failed for operation"}
    end
  end
end
