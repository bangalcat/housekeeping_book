alias HousekeepingBook.Households
[ct | _] = Households.Category.top_categories!()
[sub | _] = HousekeepingBook.Accounts.User.list_users!()

r1 =
  %{
    date: ~U[2024-02-24 17:43:00Z],
    description: "test record #{1}",
    amount: 10000,
    subject_id: sub.id,
    category_id: ct.id,
    payment: :check_card
  }

Ash.bulk_destroy!(Households.Record, :destroy, %{})
Households.Record.create!(r1)
