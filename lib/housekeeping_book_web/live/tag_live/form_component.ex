defmodule HousekeepingBookWeb.TagLive.FormComponent do
  use HousekeepingBookWeb, :live_component

  alias HousekeepingBook.Households

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tag records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tag-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Tag</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{tag: tag} = assigns, socket) do
    form = for_create_or_update(tag, %{}, assigns.action)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(form)}
  end

  @impl true
  def handle_event("validate", %{"tag" => tag_params}, socket) do
    form =
      socket.assigns.tag
      |> for_create_or_update(tag_params, socket.assigns.action)

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    save_tag(socket, socket.assigns.action, tag_params)
  end

  defp save_tag(socket, :edit, tag_params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, "Tag updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp save_tag(socket, :new, tag_params) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, "Tag created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
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
          as: "tag",
          api: Households,
          forms: [auto?: true]
        )
        |> AshPhoenix.Form.validate(params)

      :new ->
        Households.Tag
        |> AshPhoenix.Form.for_create(:create,
          as: "tag",
          api: Households,
          forms: [auto?: true]
        )
        |> AshPhoenix.Form.validate(params)
    end
  end
end
