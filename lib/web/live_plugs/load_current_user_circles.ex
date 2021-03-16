defmodule Bonfire.Web.LivePlugs.LoadCurrentUserCircles do

  use Bonfire.Web, :live_plug
  alias Bonfire.Me.Users.Circles
  alias Bonfire.Data.Identity.User

  def mount(_, _, %{assigns: %{current_user: %User{}=user}}=socket) do
    {:ok, assign(socket, :my_circles, Circles.list_my(user))}
  end

end