defmodule HousekeepingBookWeb.UserLive.FormComponent do
  use HousekeepingBookWeb, :live_component

  require Logger
  alias HousekeepingBook.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" phx-debounce />
        <.input field={@form[:email]} type="text" label="Email" phx-debounce />
        <.input field={@form[:password]} type="password" label="Password" phx-debounce />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Password Confirmation"
          phx-debounce
        />
        <.input field={@form[:type]} type="text" label="Type" phx-debounce />
        <.input field={@form[:secret_code]} type="text" label="Secret Code" phx-debounce />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    form = for_create_or_update(user, %{}, assigns.action)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(form)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      socket.assigns.user
      |> for_create_or_update(user_params, socket.assigns.action)

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, form} ->
        Logger.error("#{inspect(form.errors)}")
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_form(socket, %AshPhoenix.Form{} = form) do
    assign(socket, :form, to_form(form))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp for_create_or_update(tag, params, live_action) do
    case live_action do
      :edit ->
        tag
        |> AshPhoenix.Form.for_update(:update,
          as: "user",
          forms: [auto?: true]
        )
        |> AshPhoenix.Form.validate(params)

      :new ->
        Accounts.User
        |> AshPhoenix.Form.for_create(:register,
          as: "user",
          forms: [auto?: true]
        )
        |> AshPhoenix.Form.validate(params)
    end
  end
end
