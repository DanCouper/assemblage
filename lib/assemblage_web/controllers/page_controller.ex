defmodule AssemblageWeb.PageController do
  use AssemblageWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
