defmodule HousekeepingBookWeb.RecordLive.Index do
  use HousekeepingBookWeb, :live_view
  require Logger

  alias HousekeepingBook.Records
  alias HousekeepingBook.Categories
  alias HousekeepingBook.Accounts
  alias HousekeepingBook.Schema.Record
  alias HousekeepingBook.Schema.Category
  alias HousekeepingBook.Schema.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_options()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Record")
    |> assign(:record, Records.get_record!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Record")
    |> assign(:record, %Record{})
  end

  defp apply_action(socket, :index, params) do
    case Records.list_records(params, %{with_category: true, with_subject: true, with_tags: true}) do
      {:ok, {records, meta}} ->
        socket
        |> assign(:page_title, "Listing Records")
        |> assign(:record, nil)
        |> assign(%{records: records, meta: meta})

      {:error, meta} ->
        Logger.debug(inspect(meta))
        socket
    end
  end

  defp assign_options(socket) do
    categories = Categories.bottom_categories() |> Enum.map(&category_option/1)
    subjects = Accounts.list_users() |> Enum.map(&subject_option/1)
    category_types = Categories.category_type_options()
    payment_types = Records.record_payment_options()

    options = %{
      category: categories,
      subject: subjects,
      payment: payment_types,
      category_type: category_types,
      payment_type: payment_types
    }

    socket
    |> assign(:options, options)
  end

  defp category_option(%Category{} = category) do
    {"#{category.name} (#{category.type})", category.id}
  end

  defp subject_option(%User{} = subject) do
    {subject.name, subject.id}
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/records?#{params}")}
  end

  @impl true
  def handle_event("select-per-page", %{"page-size" => per_page} = _params, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    socket = push_patch(socket, to: ~p"/records?#{params}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    record = Records.get_record!(id)
    {:ok, _} = Records.delete_record(record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  @impl true
  def handle_info({HousekeepingBookWeb.RecordLive.FormComponent, {:saved, _record}}, socket) do
    {:noreply, push_patch(socket, to: ~p"/records")}
  end

  defp category_name(%{category: nil}), do: nil
  defp category_name(%{category: %{name: name}}), do: name

  defp category_type(%{category: nil}), do: nil

  defp category_type(%{category: %{type: type}}) do
    case type do
      :expense -> gettext("Expense")
      :income -> gettext("Income")
    end
  end

  defp subject_name(%{subject: nil}), do: nil
  defp subject_name(%{subject: %{name: name}}), do: name
end
