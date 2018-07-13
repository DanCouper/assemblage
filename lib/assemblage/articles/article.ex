defmodule Assemblage.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias Assemblage.Accounts.User

  schema "articles" do
    field :title, :string
    field :description, :string

    belongs_to :user, User
    embeds_many :sections, __MODULE__.Section

    timestamps()
  end

  defmodule Assemblage.Article.Section do
    use Ecto.Schema

    # TODO how do I validate on an embedded schema? TBQH I don't think I can,
    # And this stuff should be configured front-end, where I can validate by
    # providing a dropdown for type.
    # TODO look at Ecto.Multi for this and other cross-cutting concerns.
    @section_types ~w[codeblock figure text]
    @default_section_type "text"

    embedded_schema do
      field :type, :string, default: @default_section_type
      field :section_title, :string
      field :section_body, :string
    end
  end


  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :description, :sections])
    |> validate_required([:title, :description, :sections])
  end
end
