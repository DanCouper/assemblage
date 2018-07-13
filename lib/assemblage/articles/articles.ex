defmodule Assemblage.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false

  alias Assemblage.Article
  alias Assemblage.Repo
  alias Assemblage.Accounts.User

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Article
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Returns the list of all articles belonging to a user.

  ## Examples

      iex> list_articles(%User{})
      [%Image{}, ...]

  """
  def list_user_articles(%User{} = user) do
    Article
    |> user_articles_query(user)
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id) do
    Article
    |> Repo.get!(id)
    |> preload_user()
  end

  @doc """
  Given a user and an article ID, gets an article belonging to that user.
  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_article!(123)
      %Image{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_article!(%User{} = user, id) do
    from(a in Article, where: a.id == ^id)
    |> user_articles_query(user)
    |> Repo.one!()
    |> preload_user()
end

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(%User{} = user, attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%User{} = user, %Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> put_user(user)
    |> Repo.update()
  end

  @doc """
  Deletes a Article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{source: %Article{}}

  """
  def change_article(%User{} = user, %Article{} = article) do
    article
    |> Article.changeset(%{})
    |> put_user(user)
  end

  # HELPERS

  # Preloads the association for users of articles.
  defp preload_user(article_or_articles) do
    Repo.preload(article_or_articles, :user)
  end

  # Helper to ensure applied changes to articles
  # also update that specific user.
  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  # Ensure articles returned belong to a specific user.
  defp user_articles_query(query, %User{id: user_id}) do
    from(a in query, where: a.user_id == ^user_id)
  end
end
