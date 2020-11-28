defmodule Bonfire.Me.Identity.Users.CreateUserFields do

  use Ecto.Schema
  alias Ecto.Changeset
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Me.Identity.Users.CreateUserFields

  embedded_schema do
    field :username, :string
    field :name, :string
    field :summary, :string
    field :account_id, :integer
  end

  @cast [:username, :name, :summary]
  @required @cast
  # @defaults [
  #   cast: [:username, :name, :summary],
  #   required: [:username, :name, :summary],
  # ]

  def changeset(form \\ %CreateUserFields{}, attrs, %Account{id: id}) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(account_id: id)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:username, ~r(^[a-z][a-z0-9_]{2,30}$)i)
    |> Changeset.validate_length(:name, min: 3, max: 50)
    |> Changeset.validate_length(:summary, min: 5, max: 500)
  end

end
