defmodule HousekeepingBook.Households.Category do
  use Ash.Resource,
    domain: HousekeepingBook.Households,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  code_interface do
    define :read

    define :top_categories
    define :child_categories, args: [:id]

    define :update
    define :create
    define :delete, action: :destroy
  end

  actions do
    defaults [:read, :destroy]
    default_accept [:name, :type, :parent_id]

    create :create do
    end

    update :update do
      validate attribute_does_not_equal(:parent_id, ref(:id))
    end

    read :by_id do
      get_by [:id]
    end

    read :by_name_and_type do
      get_by [:name, :type]
    end

    read :top_categories do
      filter expr(is_nil(parent_id))
    end

    read :child_categories do
      argument :id, :integer
      filter expr(parent_id == ^arg(:id))
      prepare build(load: [:children])
    end

    read :bottom_categories do
      filter expr(is_nil(children))
    end
  end

  attributes do
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :type, HousekeepingBook.Households.CategoryType do
      default :expense
      allow_nil? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, __MODULE__ do
      attribute_writable? true
    end

    has_many :children, __MODULE__, destination_attribute: :parent_id
  end

  postgres do
    table "categories"
    repo HousekeepingBook.Repo
  end
end
