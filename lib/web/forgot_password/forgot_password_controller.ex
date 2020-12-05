defmodule Bonfire.Me.Web.ForgotPasswordController do
  use Bonfire.Web, :controller
  alias Bonfire.Me.Web.ForgotPasswordLive

  def index(conn, _), do: live_render_with_conn(conn, ForgotPasswordLive)

  def create(conn, _), do: live_render_with_conn(conn, ForgotPasswordLive)

end
