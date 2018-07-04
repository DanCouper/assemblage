defmodule AssemblageWeb.ImageController do
  use AssemblageWeb, :controller

  alias Assemblage.Multimedia
  alias Assemblage.Multimedia.Image

  @doc """
  This overrides the default `action` callback
  that the controller defines. This simply adds the
  curent user to the list for the actions to avoid adding
  in more boilerplate to the other funtions in the module.
  """
  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, current_user) do
    images = Multimedia.list_user_images(current_user)
    render(conn, "index.html", images: images)
  end

  def new(conn, _params, current_user) do
    changeset = Multimedia.change_image(current_user, %Image{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"image" => image_params}, current_user) do
    case Multimedia.create_image(current_user, image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image created successfully.")
        |> redirect(to: Routes.image_path(conn, :show, image))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    image = Multimedia.get_user_image!(current_user, id)
    render(conn, "show.html", image: image)
  end

  def edit(conn, %{"id" => id}, current_user) do
    image = Multimedia.get_user_image!(current_user, id)
    changeset = Multimedia.change_image(current_user, image)
    render(conn, "edit.html", image: image, changeset: changeset)
  end

  def update(conn, %{"id" => id, "image" => image_params}, current_user) do
    image = Multimedia.get_user_image!(current_user, id)

    case Multimedia.update_image(image, image_params) do
      {:ok, image} ->
        conn
        |> put_flash(:info, "Image updated successfully.")
        |> redirect(to: Routes.image_path(conn, :show, image))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", image: image, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    image = Multimedia.get_user_image!(current_user, id)
    {:ok, _image} = Multimedia.delete_image(image)

    conn
    |> put_flash(:info, "Image deleted successfully.")
    |> redirect(to: Routes.image_path(conn, :index))
  end
end
