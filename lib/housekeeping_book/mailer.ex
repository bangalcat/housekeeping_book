defmodule HousekeepingBook.Mailer do
  use Boundary, deps: []
  use Swoosh.Mailer, otp_app: :housekeeping_book
end
