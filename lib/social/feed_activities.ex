defmodule Bonfire.Me.Social.FeedActivities do

  alias Bonfire.Data.Social.{Feed, FeedPublish}
  alias Bonfire.Data.Identity.{User}
  alias Bonfire.Me.Social.Feeds
  alias Bonfire.Me.Social.Activities
  alias Bonfire.Common.Utils

  use Bonfire.Repo.Query,
      schema: FeedPublish,
      searchable_fields: [:id, :feed_id, :verb],
      sortable_fields: [:id]

  def my_feed(user, cursor_after \\ nil) do

    # feeds the user is following
    feed_ids = Feeds.my_feed_ids(user)
    # IO.inspect(inbox_feed_ids: feed_ids)

    # CommonsPub.Utils.Web.CommonHelper.pubsub_subscribe(feed_ids, socket)

    feed(feed_ids, cursor_after)
  end

  def feed(%{id: feed_id}, cursor_after \\ nil), do: feed(feed_id, cursor_after)

  def feed(feed_id, cursor_after) when is_binary(feed_id) do
    build_query(feed_id: feed_id)
      |> do_feed(cursor_after)
  end

  def feed(feed_ids, cursor_after) when is_list(feed_ids) do
    build_query(feed_id__in: feed_ids)
      |> do_feed(cursor_after)
  end

  def do_feed(q, cursor_after \\ nil) do
    q
      |> preload_join(:activity)
      |> preload_join(:activity, :verb)
      |> preload_join(:activity, :object)
      |> preload_join(:activity, :object_post)
      |> preload_join(:activity, :object_post, :post_content)
      |> preload_join(:activity, :reply_to)
      |> preload_join(:activity, :subject_profile)
      |> preload_join(:activity, :subject_character)
      |> Bonfire.Repo.many_paginated(before: cursor_after)
  end

  def live_more(feed_id, %{"after" => cursor_after} = attrs, socket) when is_binary(feed_id), do: Bonfire.Me.Social.FeedActivities.feed(feed_id, cursor_after) |> live_more(socket)

  def my_live_more(%{"after" => cursor_after} = attrs, socket), do: Bonfire.Me.Social.FeedActivities.my_feed(socket.assigns.current_user, cursor_after) |> live_more(socket)

  def live_more(%{} = feed, socket) do
    # IO.inspect(feed_pagination: feed)
    {:noreply,
      socket
      |> Phoenix.LiveView.assign(
        feed: socket.assigns.feed ++ Utils.e(feed, :entries, []),
        page_info: Utils.e(feed, :metadata, [])
      )}
  end

  # def feed(%{feed_publishes: _} = feed_for, _) do
  #   repo().maybe_preload(feed_for, [feed_publishes: [activity: [:verb, :object, subject_user: [:profile, :character]]]]) |> Map.get(:feed_publishes)
  # end

  @doc """
  Creates a new local activity and publishes to appropriate feeds
  """
  def publish(subject, verb, object) when is_atom(verb) do
    do_publish(subject, verb, object, Feeds.instance_feed_id())
  end

  @doc """
  Records a remote activity and puts in appropriate feeds
  """
  def save_fediverse_incoming_activity(subject, verb, object) when is_atom(verb) do
    do_publish(subject, verb, object, Feeds.fediverse_feed_id())
  end

  defp do_publish(subject, verb, object, extra_feed) do
    with {:ok, activity} = Activities.create(subject, verb, object),
    {:ok, _published} <- feed_publish(subject, activity), # publish in user's timeline
    {:ok, _published} <- feed_publish(extra_feed, activity) # publish in local instance or fediverse feed
     do
      {:ok, activity}
    end
  end

  defp feed_publish(feed_or_subject, activity) do
    with {:ok, feed} = Feeds.feed_for_id(feed_or_subject) do
      do_feed_publish(feed, activity)
    end
  end

  defp do_feed_publish(%{id: feed_id}, %{id: object_id}) do
    attrs = %{feed_id: feed_id, object_id: object_id}
    repo().put(FeedPublish.changeset(attrs))
  end

end
