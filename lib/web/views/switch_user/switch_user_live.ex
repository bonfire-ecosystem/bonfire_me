defmodule Bonfire.Me.Web.SwitchUserLive do
  use Bonfire.Web, :live_view
  alias Bonfire.Web.LivePlugs

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.LoadCurrentAccountUsers,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(_, _, socket), do: {:ok, assign(socket, current_user: nil) |> assign(:go, Map.get(socket.assigns, :go, ""))
}

end
