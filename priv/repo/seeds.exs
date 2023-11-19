# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HousekeepingBook.Repo.insert!(%HousekeepingBook.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias HousekeepingBook.Records.Importer.CsvImporter

Code.eval_file("priv/repo/categories_seeds.exs")

Application.app_dir(:housekeeping_book, "priv")
|> Path.join("account-book-records.csv")
|> File.stream!()
|> CsvImporter.import_records(mapper: &CsvImporter.my_mapper/1)
