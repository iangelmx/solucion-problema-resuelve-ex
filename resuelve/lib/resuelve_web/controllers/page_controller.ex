defmodule ResuelveWeb.PageController do
  use ResuelveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
