defmodule Bonfire.Me.Web.ProfileLive do
  use Bonfire.Web, :live_view
  alias Bonfire.Me.Web.HeroProfileLive
  alias Bonfire.Me.Web.ProfileNavigationLive
  alias Bonfire.Me.Web.ProfileAboutLive
  alias Bonfire.Me.Fake
  alias Bonfire.Web.LivePlugs
  import Bonfire.Me.Integration

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.LoadCurrentUserCircles,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(params, session, socket) do

    current_user = e(socket.assigns, :current_user, nil)

    user = case Map.get(params, "username") do
      nil -> e(socket.assigns, :current_user, Fake.user_live())
      username ->
        with {:ok, user} <- Bonfire.Me.Users.by_username(username) do
          user
        end
    end
    IO.inspect(user: user)

    following = if current_user && user && module_enabled?(Bonfire.Social.Follows), do: Bonfire.Social.Follows.following?(current_user, user)

    {:ok,
      socket
      |> assign(
        page: "profile",
        page_title: "Profile",
        selected_tab: "timeline",
        smart_input: true,
        feed_title: "User timeline",
        current_account: Map.get(socket.assigns, :current_account),
        current_user: current_user,
        user: user, # the user to display
        following: following
      )}
  end

  def handle_params(%{"tab" => "posts" = tab} = _params, _url, socket) do
    current_user = e(socket.assigns, :current_user, nil)

    feed = if module_enabled?(Bonfire.Social.Posts), do: Bonfire.Social.Posts.list_by(e(socket.assigns, :user, :id, nil), current_user) #|> IO.inspect

    {:noreply,
     assign(socket,
       selected_tab: tab,
       feed: e(feed, :entries, []),
       page_info: e(feed, :metadata, [])
     )}
  end

  def handle_params(%{"tab" => "boosts" = tab} = _params, _url, socket) do
    current_user = e(socket.assigns, :current_user, nil)

    feed = if module_enabled?(Bonfire.Social.Boosts), do: Bonfire.Social.Boosts.list_by(e(socket.assigns, :user, :id, nil), current_user) #|> IO.inspect

    {:noreply,
      assign(socket,
        selected_tab: tab,
        feed: e(feed, :entries, []),
        page_info: e(feed, :metadata, [])
      )}
  end

  def handle_params(%{"tab" => "timeline" = tab} = _params, _url, socket) do

    handle_params(%{}, nil, socket)
  end

  def handle_params(%{"tab" => tab} = _params, _url, socket) do
    IO.inspect(tab: tab)
    {:noreply,
     assign(socket,
       selected_tab: tab
     )}
  end

  def handle_params(%{} = _params, _url, socket) do
    IO.inspect(tab: "default")

    current_user = e(socket.assigns, :current_user, nil)

     # feed = if user, do: Bonfire.Social.Activities.by_user(user)
     feed_id = e(socket.assigns, :user, :id, nil)
     feed = if feed_id && module_enabled?(Bonfire.Social.FeedActivities), do: Bonfire.Social.FeedActivities.feed(feed_id, current_user)
     #IO.inspect(feed: feed)

    {:noreply,
     assign(socket,
     selected_tab: "timeline",
     feed: e(feed, :entries, []),
     page_info: e(feed, :metadata, [])
     )}
  end

  def handle_event(action, attrs, socket), do: Bonfire.Web.LiveHandler.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Web.LiveHandler.handle_info(info, socket, __MODULE__)

end
