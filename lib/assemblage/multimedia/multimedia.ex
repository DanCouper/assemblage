defmodule Assemblage.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias Assemblage.Accounts
  alias Assemblage.Repo
  alias Assemblage.Multimedia.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Image
    |> Repo.all()
    |> preload_user()
  end

  def list_user_images(%Accounts.User{} = user) do
    Image
    |> user_images_query(user)
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: preload_user(Repo.get!(Image, id))


  def get_user_image!(%Accounts.User{} = user, id) do
    from(i in Image, where: i.id == ^id)
    |> user_images_query(user)
    |> Repo.one!()
    |> preload_user()
  end
  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(%Accounts.User{} = user, attrs \\ %{}) do
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

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Accounts.User{} = user, %Image{} = image) do
    image
    |> Image.changeset(%{})
    |> put_user(user)
  end

  defp preload_user(image_or_images) do
    Repo.preload(image_or_images, :user)
  end

  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  defp user_images_query(query, %Accounts.User{id: user_id}) do
    from(i in query, where: i.user_id == ^user_id)
  end
end
