defmodule AssemblageWeb.Schema.Middleware.ChangesetErrors do
  @behaviour Absinthe.Middleware

  @moduledoc """
  Inside Absinthe's resolution structs, the two most significant keys are
  `:value` and `:errors`. `:value` holds the value that will eventually
  be returned for a field, and will be the parent for any subsequent fields.
  `:errors` is ultimately combined with errors from every other field.

  When an `{:ok, value}` tuple is returned from a resolver, the value is,
  naturally, placed in the `:value` field, whilst the `{:error, reason}`
  has the reason added to the errors field.

  This is useful in some cases, but ideally errors relating to specific
  resolvers should scope to the field they relate to.


  With that in mind, this middleware deals gracefully with any changeset
  errors that crop up, allowing specific feedback to be provided at point
  of failure.
  """

  def call(res, _) do
    with %{errors: [%Ecto.Changeset{} = changeset]} <- res do
      %{res | value: %{errors: transform_errors(changeset)}, errors: []}
    end
  end

  @spec transform_errors(Ecto.Changeset.t()) :: [String.t()]
  defp transform_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn {k, v} -> %{key: k, value: v} end)
  end

  @spec format_error(Ecto.Changeset.error()) :: String.t()
  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end
end
