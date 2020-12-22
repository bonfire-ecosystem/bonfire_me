defmodule Bonfire.Me.Web.ForgotPasswordLive do
  use Bonfire.Web, :live_view
  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Identity.Accounts

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(params, session, socket) do
    {:ok,
     socket
      |> assign_new(:form, &form/0)}
  end

  defp form(), do: Accounts.changeset(:change_password, %{})


end
