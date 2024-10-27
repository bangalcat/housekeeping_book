defmodule HousekeepingBookWeb.UserSettingsLive do
  use HousekeepingBookWeb, :live_view

  alias HousekeepingBook.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="space-y-12 divide-y w-full">
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <:actions>
            <.button phx-disable-with="Changing..." disabled={@email_form.errors != []}>
              Change Email
            </.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/sign-in?action=password-update"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@info_form}
          id="info_form"
          phx-submit="update_info"
          phx-change="validate_info"
        >
          <.input field={@info_form[:name]} type="text" label="Name" required />
          <.input
            field={@info_form[:timezone]}
            type="text"
            label="Timezone"
            list="matches"
            phx-debounce="600"
            required
          />

          <datalist id="matches">
            <option :for={{name, abbr, offset} <- @matches} value={name}>
              <%= "#{name} (#{abbr}) #{div(offset, 3600)}" %>
            </option>
          </datalist>

          <:actions>
            <.button phx-disable-with="Saving...">Save</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = AshPhoenix.Form.for_update(user, :update_email, as: "user")
    password_changeset = AshPhoenix.Form.for_update(user, :update_password, as: "user")
    info_changeset = AshPhoenix.Form.for_update(user, :update, as: "user")

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:info_form, to_form(info_changeset))
      |> assign(:matches, [])
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.email_form
      |> AshPhoenix.Form.validate(user_params)

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params

    case AshPhoenix.Form.submit(socket.assigns.email_form, params: user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Confirm email has been sent. Please check your email.")
         |> assign(:current_user, user)}

      {:error, form} ->
        {:noreply, assign(socket, :email_form, form)}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.password_form
      |> AshPhoenix.Form.validate(Map.put(user_params, "current_password", password || "-"),
        target: ["password", "password_confirmation"]
      )

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    case AshPhoenix.Form.submit(
           socket.assigns.password_form,
           Map.put(user_params, "current_password", password)
         ) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password has been changed")
         |> assign(:current_user, user)}

      {:error, form} ->
        {:noreply, assign(socket, password_form: form)}
    end
  end

  def handle_event("validate_info", params, socket) do
    %{"user" => user_params} = params

    timezone_matches = user_params["timezone"] |> matched_timezone_list()

    info_form =
      socket.assigns.info_form
      |> AshPhoenix.Form.validate(user_params)

    {:noreply, assign(socket, info_form: info_form, matches: timezone_matches)}
  end

  def handle_event("update_info", params, socket) do
    %{"user" => user_params} = params

    case AshPhoenix.Form.submit(socket.assigns.info_form, params: user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "User updated successfully")}

      {:error, form} ->
        {:noreply, assign(socket, info_form: form)}
    end
  end

  def matched_timezone_list(""), do: []

  def matched_timezone_list(str) do
    now = DateTime.utc_now()

    Tzdata.zone_list()
    |> Enum.filter(&(&1 =~ ~r/^#{str}/i))
    |> Enum.map(fn zone ->
      shifted = DateTime.shift_zone!(now, zone)

      {zone, shifted.zone_abbr, shifted.utc_offset}
    end)
    |> Enum.uniq()
  end
end
