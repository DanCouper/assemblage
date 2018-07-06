defmodule Factory do
  def create_user do
    int = :erlang.unique_integer([:positive, :monotonic])
    params = %{
      username: "sexysaruman#{int}",
      credential: %{ email: "saruman#{int}@palantir.com", password: "isengard" }
    }

    Assemblage.Accounts.register_user(params)
  end
end
