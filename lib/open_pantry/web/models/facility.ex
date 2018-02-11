defmodule OpenPantry.Facility do
  use OpenPantry.Web, :model
  schema "facilities" do
    field :name, :string
    field :subdomain, :string
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :max_occupancy, :integer
    field :square_meterage_storage, :float
    many_to_many :users, OpenPantry.User, join_through: "user_facilities"
    has_many :stocks, OpenPantry.Stock, on_delete: :delete_all
    has_many :foods, through: [:stocks, :food]
    has_many :food_groups, through: [:foods, :food_group]
    has_many :credit_types, through: [:food_groups, :credit_types]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :subdomain, :address1, :address2, :city, :region, :postal_code, :max_occupancy, :square_meterage_storage])
    |> unique_constraint(:name)
    |> unique_constraint(:subdomain)
    |> validate_required([:name])
  end

end
