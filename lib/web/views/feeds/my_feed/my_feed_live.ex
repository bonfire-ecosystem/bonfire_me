defmodule Bonfire.Me.Web.MyFeedLive do
  use Bonfire.Web, :live_view
  alias Bonfire.Fake
  alias Bonfire.Common.Web.LivePlugs
  alias Bonfire.Me.Identity.Users
  alias Bonfire.Me.Web.{CreateUserLive}
  alias Bonfire.UI.Social.FeedLive

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

  defp mounted(params, session, socket) do

    feed = Bonfire.Me.Social.FeedActivities.my_feed(socket.assigns.current_user)

    {:ok, socket
    |> assign(
      page: "feed",
      page_title: "My Feed",
      feed_title: "My Feed",
      feed: e(feed, :entries, []),
      page_info: e(feed, :metadata, [])
      )}

  end


  # def handle_params(%{"tab" => tab} = _params, _url, socket) do
  #   {:noreply,
  #    assign(socket,
  #      selected_tab: tab
  #    )}
  # end

  # def handle_params(%{} = _params, _url, socket) do
  #   {:noreply,
  #    assign(socket,
  #      current_user: Fake.user_live()
  #    )}
  # end

  # def handle_event("feed_load_more", attrs, socket), do: Bonfire.Me.Web.LiveHandlers.Feeds.my_live_more(attrs, socket)

  # def handle_event("post", attrs, socket), do: Bonfire.Me.Social.Posts.live_post(attrs, socket)
  defdelegate handle_event(action, attrs, socket), to: Bonfire.Me.Web.LiveHandlers

  # def handle_info(%Bonfire.Data.Social.FeedPublish{}=fp, socket), do: Bonfire.Me.Social.FeedActivities.live_add(fp, socket)
  defdelegate handle_info(action, attrs, socket), to: Bonfire.Me.Web.LiveHandlers

end
