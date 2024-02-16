defmodule HousekeepingBook.Households.PaymentType do
  use Ash.Type.Enum, values: [:cash, :check_card, :credit_card, :bank_transfer, :pay, :other]
end
