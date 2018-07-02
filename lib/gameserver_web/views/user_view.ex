defmodule GameserverWeb.UserView do
  use GameserverWeb, :view

  alias Gameserver.Accounts

  def first_name(%Accounts.User{name: name}) do
    [fname|_rest] = String.split(name, " ")
    fname
  end
end
