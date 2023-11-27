defmodule HousekeepingBookWeb.RecordLiveTest do
  use HousekeepingBookWeb.ConnCase

  import Phoenix.LiveViewTest
  import HousekeepingBook.RecordsFixtures
  import HousekeepingBook.AccountsFixtures
  import HousekeepingBook.CategoriesFixtures

  @create_attrs %{
    # date: "2023-11-15T05:48:00Z",
    date: DateTime.utc_now(),
    description: "some description",
    amount: 42,
    payment: :cash,
    subject_id: nil
  }
  @update_attrs %{
    date: "2023-11-16T05:48:00Z",
    description: "some updated description",
    amount: 43
  }
  @invalid_attrs %{
    date: nil,
    description: nil,
    amount: nil
  }

  @moduletag :current

  describe "Index" do
    setup [:setup_record, :register_and_log_in_user]

    test "lists all records", %{conn: conn, record: record} do
      {:ok, _index_live, html} = live(conn, ~p"/records")

      assert html =~ "Listing Records"
      assert html =~ record.description
    end

    test "saves new record", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert index_live
             |> element("a", "New Record")
             |> render_click() =~ "New Record"

      assert_patch(index_live, ~p"/records/new")

      assert index_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#record-form", record: @create_attrs)
             |> render_submit()

      html = render(index_live)
      # assert html =~ "Record created successfully"
      assert html =~ "some description"
    end

    test "updates record in listing", %{conn: conn, record: record} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert index_live
             |> element("#records-#{record.id} a[href*='edit']")
             |> render_click() =~
               "Edit Record"

      assert_patch(index_live, ~p"/records/#{record}/edit")

      assert index_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#record-form", record: @update_attrs)
             |> render_submit()

      html = render(index_live)
      # assert html =~ "Record updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes record in listing", %{conn: conn, record: record} do
      {:ok, index_live, _html} = live(conn, ~p"/records")

      assert index_live
             |> element("#records-#{record.id} a[data-confirm*='sure']")
             |> render_click()

      refute has_element?(index_live, "#records-#{record.id}")
    end
  end

  describe "Show" do
    setup [:setup_record, :register_and_log_in_user]

    test "displays record", %{conn: conn, record: record} do
      {:ok, _show_live, html} = live(conn, ~p"/records/#{record}")

      assert html =~ "Show Record"
      assert html =~ record.description
    end

    test "updates record within modal", %{conn: conn, record: record} do
      {:ok, show_live, _html} = live(conn, ~p"/records/#{record}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Record"

      assert_patch(show_live, ~p"/records/#{record}/show/edit")

      assert show_live
             |> form("#record-form", record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#record-form", record: @update_attrs)
             |> render_submit()

      html = render(show_live)
      # assert html =~ "Record updated successfully"
      assert html =~ "some updated description"
    end
  end

  defp setup_record(_) do
    user = user_fixture()
    category = category_fixture()
    record = record_fixture(user, category)
    %{record: record}
  end
end
