defmodule Assemblage.MultimediaTest do
  use Assemblage.DataCase

  alias Assemblage.Multimedia

  describe "images" do
    alias Assemblage.Multimedia.Image

    @valid_attrs %{description: "some description", full_url: "some full_url", title: "some title"}
    @update_attrs %{description: "some updated description", full_url: "some updated full_url", title: "some updated title"}
    @invalid_attrs %{description: nil, full_url: nil, title: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Multimedia.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Multimedia.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Multimedia.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Multimedia.create_image(@valid_attrs)
      assert image.description == "some description"
      assert image.full_url == "some full_url"
      assert image.title == "some title"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, %Image{} = image} = Multimedia.update_image(image, @update_attrs)
      
      assert image.description == "some updated description"
      assert image.full_url == "some updated full_url"
      assert image.title == "some updated title"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_image(image, @invalid_attrs)
      assert image == Multimedia.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Multimedia.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Multimedia.change_image(image)
    end
  end
end
