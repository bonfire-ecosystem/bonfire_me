defmodule Bonfire.Me.Web.LoginLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Social.Web.LayoutView, "empty_template.html"}]}
  alias Bonfire.Me.Accounts

  # because this isn't a live link and it will always be accessed by a
  # guest, it will always be offline
  def mount(params, session, socket) do
    {:ok,
     socket
      |> assign_new(:current_account, fn -> nil end)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:error, fn -> nil end)
      |> assign_new(:feed_title, fn -> "Public Feed" end)
      |> assign_new(:form, fn -> login_form(params) end)
      |> assign_new(:conn, fn -> session["conn"] end)
    }
  end

  defp login_form(params), do: Accounts.changeset(:login, params)

end
