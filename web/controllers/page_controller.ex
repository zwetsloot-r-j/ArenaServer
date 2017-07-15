defmodule ArenaServer.PageController do
  use ArenaServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
