defmodule Assemblage.Multimedia do
  @moduledoc """
  The Multimedia context.

  Tied into the Accounts context to associate multimedia
  items with users.

  TODO Currently only images.
  TODO Will also need a posts context to associate with -
  multimedia items belong to both users and to posts.
  """

  import Ecto.Query, warn: false
  alias Assemblage.Accounts.User
  alias Assemblage.Repo
  alias Assemblage.Multimedia.Image

  @doc """
  Returns the list of all images.
  REVIEW: not sustainable in the case of there being a huge number of images?

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Image
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Returns the list of all images belonging to a user.

  ## Examples

      iex> list_images(%User{})
      [%Image{}, ...]

  """
  def list_user_images(%User{} = user) do
    Image
    |> user_images_query(user)
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Given an image ID, gets an image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: preload_user(Repo.get!(Image, id))

  @doc """
  Given a user and an image ID, gets an image belonging to that user.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_image!(%User{} = user, id) do
    from(i in Image, where: i.id == ^id)
    |> user_images_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  @doc """
  Given a user and an image, creates a image for that user.

  ## Examples

      iex> create_image(%User{}, %{field: value})
      {:ok, %Image{}}

      iex> create_image(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(%User{} = user, attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(user, image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%User{} = user, %Image{} = image) do
    image
    |> Image.changeset(%{})
    |> put_user(user)
  end

  # Preloads the association for users of images.
  defp preload_user(image_or_images) do
    Repo.preload(image_or_images, :user)
  end

  # Helper to ensure applied changes to images
  # also update that specific user.
  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  # Ensure images returned belong to a specific user.
  defp user_images_query(query, %User{id: user_id}) do
    from(i in query, where: i.user_id == ^user_id)
  end
end
