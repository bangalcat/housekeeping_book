defmodule HousekeepingBookWeb.CustomComponents do
  use Phoenix.Component

  import Flop.Phoenix
  import HousekeepingBookWeb.CoreComponents
  import Phoenix.HTML.Tag

  attr :meta, Flop.Meta, required: true
  attr :id, :string, default: nil
  attr :on_change, :string, default: "update-filter"
  attr :target, :string, default: nil
  attr :fields, :list

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form for={@form} id={@id} phx-target={@target} phx-change={@on_change} phx-submit={@on_change}>
      <.filter_fields :let={i} form={@form} fields={@fields}>
        <.input field={i.field} label={i.label} type={i.type} phx-debounce={120} {i.rest} />
      </.filter_fields>

      <.button class="my-2" name="reset">reset</.button>
    </.form>
    """
  end

  def pagination_opts do
    [
      ellipsis_attrs: [class: "hero-ellipsis-horizontal"],
      ellipsis_content: "‥",
      next_link_attrs: [class: "hover:text-zinc-700"],
      next_link_content: next_icon(),
      page_links: {:ellipsis, 5},
      pagination_list_attrs: [class: "flex justify-center gap-12"],
      pagination_link_attrs: [class: "pagination-link"],
      pagination_link_aria_label: &"Go to #{&1}",
      previous_link_attrs: [class: "hover:text-zinc-700"],
      previous_link_content: previous_icon(),
      wrapper_attrs: [class: "flex justify-center gap-4"]
    ]
  end

  defp next_icon do
    content_tag(:span, "", class: "hero-chevron-right")
  end

  defp previous_icon do
    content_tag(:span, "", class: "hero-chevron-left")
  end

  def table_opts do
    [
      container: true,
      container_attrs: [class: "table-container"],
      no_results_content: content_tag(:p, do: "Nothing found."),
      table_attrs: [class: "my-table"],
      tbody_attrs: [class: "my-table-body"],
      thead_attrs: [class: "my-thead"],
      tbody_td_attrs: [class: "my-tbody-td"],
      tbody_tr_attrs: [class: "my-tbody-tr"]
    ]
  end
end
