defmodule HousekeepingBookWeb.PageController do
  use HousekeepingBookWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/monthly/records")
  end
end
