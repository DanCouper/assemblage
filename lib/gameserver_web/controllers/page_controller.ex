defmodule GameserverWeb.PageController do
  use GameserverWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
