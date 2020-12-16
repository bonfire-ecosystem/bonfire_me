defmodule Bonfire.Me.Web.SignupController do
  use Bonfire.Web, :controller
  alias Bonfire.Me.Identity.Accounts
  alias Bonfire.Me.Web.SignupLive

  def index(conn, _), do: live_render(conn, SignupLive)

  def create(conn, params) do
    case Accounts.signup(Map.get(params, "account", %{})) do
      {:ok, _account} ->
        conn
        |> assign(:registered, true)
        |> live_render(SignupLive)
      {:error, :taken} ->
        conn
        |> assign(:error, :taken)
        |> live_render(SignupLive)
      {:error, changeset} ->
        IO.inspect(changeset)
        conn
        |> assign(:form, changeset)
        |> live_render(SignupLive)
    end
  end

end
