defmodule Bonfire.Me.Users.Circles do

  alias Bonfire.Data.Identity.User
  alias Bonfire.Data.Social.Named
  alias Bonfire.Data.Social.Circle
  alias Bonfire.Data.Social.Encircle
  alias Bonfire.Data.Identity.Caretaker

  alias Bonfire.Boundaries.Circles

  alias Ecto.Changeset
  import Bonfire.Me.Integration
  alias Bonfire.Common.Utils

  ## invariants:
  ## * Created circles will have the user as a caretaker


  @doc "Create a circle for the provided user (and with the user in the circle?)"
  def create(%User{}=user, name \\ nil, %{}=attrs \\ %{}) do
    repo().insert(changeset(:create,
    user,
    attrs
      |> Utils.deep_merge(%{
        named: %{name: name},
        caretaker: %{caretaker_id: user.id}
        # encircles: [%{subject_id: user.id}] # add myself to circle?
      })
    ))
  end

  def changeset(:create, %User{}=user, attrs) do
    Circles.changeset(:create, attrs)
  end

  import Ecto.Query
  import Bonfire.Boundaries.Queries

  @doc """
  Lists the circles that we are permitted to see.
  """
  def list_visible(%User{}=user) do
    repo().all(list_visible_q(user))
  end

  @doc "query for `list_visible`"
  def list_visible_q(%User{id: _}=user) do
    cs = can_see?(:circle, user)
    from circle in Circle, as: :circle,
      left_join: named in assoc(circle, :named),
      left_lateral_join: _cs in ^cs,
      preload: [named: named]
  end

  @doc """
  Lists the circles we are the registered caretakers of that we are
  permitted to see. If any circles are created without permitting the
  user to see them, they will not be shown.
  """
  def list_my(%User{}=user) do
    repo().all(list_my_q(user))
  end

  @doc "query for `list_my`"
  def list_my_q(%User{id: user_id}=user) do
    list_visible_q(user)
    |> join(:inner, [circle: circle], caretaker in assoc(circle, :caretaker), as: :caretaker)
    |> where([caretaker: caretaker], caretaker.caretaker_id == ^user_id)
  end
end
