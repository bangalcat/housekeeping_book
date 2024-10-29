defmodule HousekeepingBook.Households.PaymentType do
  use Ash.Type.Enum,
    values: [
      {:cash, "Cash"},
      {:check_card, "Check Card"},
      {:credit_card, "Credit Card"},
      {:bank_transfer, "Bank Transfer"},
      {:pay, "Pay"},
      {:other, "Other"}
    ]
end
