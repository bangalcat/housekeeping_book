defmodule HousekeepingBookWeb.LiveUserAuthTest do
  use HousekeepingBookWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias HousekeepingBookWeb.LiveUserAuth

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, HousekeepingBookWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{conn: conn}
  end

  describe "on_mount: live_user_required" do
    test "validate assigns current_user required", %{conn: conn} do
      session = get_session(conn)

      {:cont, updated_socket} =
        LiveUserAuth.on_mount(:live_user_required, %{}, session, %LiveView.Socket{
          endpoint: HousekeepingBookWeb.Endpoint,
          assigns: %{__changed__: %{}, flash: %{}, current_user: %{email: "test@test.com"}}
        })

      assert updated_socket.assigns.current_user
    end

    test "redirect to sign-in page", %{conn: conn} do
      session = get_session(conn)

      {:halt, halted_socket} =
        LiveUserAuth.on_mount(:live_user_required, %{}, session, %LiveView.Socket{
          endpoint: HousekeepingBookWeb.Endpoint,
          assigns: %{__changed__: %{}, flash: %{}}
        })

      refute halted_socket.assigns[:current_user]
    end
  end
end
