defmodule Bonfire.Me.Web.LogoutController do

  use Bonfire.Web, :controller
  alias Bonfire.Web.HomeLive

  def index(conn, _) do
    conn
    |> delete_session(:account_id)
    |> put_flash(:info, "Logged out successfully. Until next time!")
    |> redirect(to: Routes.live_path(conn, HomeLive))
  end

end
