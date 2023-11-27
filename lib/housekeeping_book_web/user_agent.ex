defmodule HousekeepingBookWeb.UserAgent do
  import Plug.Conn
  import Phoenix.Component, only: [assign_new: 3]
  import Phoenix.LiveView, only: [get_connect_info: 2]

  def fetch_user_device(conn, _opts) do
    with [agent] <- get_req_header(conn, "user-agent"),
         %UAParser.UA{device: %UAParser.Device{family: fam}} <- UAParser.parse(agent) do
      conn
      |> assign(:current_device, fam)
      |> put_session("current_device", fam)
    else
      _ -> assign(conn, :current_device, nil)
    end
  end

  def assign_user_device(socket, session) do
    socket
    |> assign_new(:current_device, fn ->
      if current_device = session["current_device"] do
        current_device
      else
        case get_connect_info(socket, :user_agent) |> UAParser.parse() do
          %UAParser.UA{device: %UAParser.Device{family: fam}} -> fam
          nil -> nil
        end
      end
    end)
  end
end
