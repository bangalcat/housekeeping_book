defmodule HousekeepingBook.Cldr do
  use Boundary, top_level?: true, deps: [HousekeepingBook], exports: [Number, DateTime]

  use Cldr,
    locales: ["en", "ko"],
    default_locale: "ko",
    otp_app: :housekeeping_book,
    gettext: HousekeepingBook.Gettext,
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
