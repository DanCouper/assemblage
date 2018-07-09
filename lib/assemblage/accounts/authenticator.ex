defmodule Assemblage.Accounts.Authenticator do
  # FIXME These values **must** be in a configuration file
  # see https://hexdocs.pm/phoenix/Phoenix.Token.html
  # NOTE Avoiding directly linking `assemblage` and `assemblage_web`:
  @context Application.get_env(:assemblage, :web_endpoint, AssemblageWeb.Endpoint)
  @salt "a_secret"
  @max_age 365 * 24 * 3600


  def generate_token(id) do
    Phoenix.Token.sign(@context, @salt, id, max_age: @max_age)
  end

  def verify_token(token) do
    Phoenix.Token.verify(@context, @salt, token, max_age: @max_age)
  end
end
