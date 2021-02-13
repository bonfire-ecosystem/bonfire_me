defmodule Bonfire.Me.Social.FeedActivities do

  alias Bonfire.Data.Social.{Feed, FeedPublish, Like}
  alias Bonfire.Data.Identity.{User}
  alias Bonfire.Me.Social.Feeds
  alias Bonfire.Me.Social.Activities
  alias Bonfire.Common.Utils

  use Bonfire.Repo.Query,
      schema: FeedPublish,
      searchable_fields: [:id, :feed_id, :object_id],
      sortable_fields: [:id]

  def my_feed(user, cursor_after \\ nil) do

    # feeds the user is following
    feed_ids = Feeds.my_feed_ids(user)
    # IO.inspect(inbox_feed_ids: feed_ids)

    feed(feed_ids, user, cursor_after)
  end

  def feed(%{id: feed_id}, current_user \\ nil, cursor_after \\ nil), do: feed(feed_id, current_user, cursor_after)

  def feed(feed_id_or_ids, current_user, cursor_after) when is_binary(feed_id_or_ids) or is_list(feed_id_or_ids) do

    Utils.pubsub_subscribe(feed_id_or_ids) # subscribe to realtime feed updates

    build_query(feed_id: feed_id_or_ids) # query FeedPublish + assocs needed in timelines/feeds
      |> preload_join(:activity)
      |> preload_join(:activity, :verb)
      |> preload_join(:activity, :object)
      |> preload_join(:activity, :object_post)
      |> preload_join(:activity, :object_post, :post_content)
      |> preload_join(:activity, :object_creator_profile)
      |> preload_join(:activity, :object_creator_character)
      |> preload_join(:activity, :reply_to)
      |> preload_join(:activity, :subject_profile)
      |> preload_join(:activity, :subject_character)
      |> maybe_my_like(current_user)
      # |> IO.inspect
      # |> Bonfire.Repo.all()
      |> Bonfire.Repo.many_paginated(before: cursor_after) # return a page of items + pagination metadata
      # |> IO.inspect
  end

  def maybe_my_like(q, %{id: current_user_id} = _current_user) do
    q
    |> join(:left, [a], l in Like, on: l.liked_id == a.object_id and l.liker_id == ^current_user_id)
    |> preload([l], activity: [:my_like])
  end
  def maybe_my_like(q, _), do: q

  def live_more(feed_id, %{"after" => cursor_after} = attrs, socket) when is_binary(feed_id), do: Bonfire.Me.Social.FeedActivities.feed(feed_id, Utils.e(socket.assigns, :current_user, nil), cursor_after) |> live_more(socket)

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

  def live_add(fp, socket) do
    IO.inspect(pubsub_received: fp)

    {:noreply,
        Phoenix.LiveView.assign(socket,
          feed: [fp] ++ Map.get(socket.assigns, :feed, [])
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
    with {:ok, activity} <- Activities.create(subject, verb, object),
    {:ok, published} <- feed_publish(subject, activity), # publish in user's timeline
    {:ok, _published} <- feed_publish(extra_feed, activity) # publish in local instance or fediverse feed
     do
      {:ok, published}
    end
  end

  defp feed_publish(feed_or_subject, activity) do
    with {:ok, %{id: feed_id} = feed} <- Feeds.feed_for_id(feed_or_subject),
    {:ok, published} <- do_feed_publish(feed, activity) do
      IO.inspect(feed_id: feed_id)

      published = %{published | activity: activity}
      IO.inspect(published: published)

      # Utils.pubsub_broadcast(feed.id, {:feed_activity, activity}) # push to online users
      Utils.pubsub_broadcast(feed_id, published) # push to online users

      {:ok, published}
    end
  end

  defp do_feed_publish(%{id: feed_id}, %{id: activity_or_object_id}) do
    attrs = %{feed_id: feed_id, object_id: activity_or_object_id}
    repo().put(FeedPublish.changeset(attrs))
  end

  @doc "Delete an activity (usage by things like unlike)"
  def delete_for_object(%{id: id}), do: delete_for_object(id)
  def delete_for_object(id) when is_binary(id), do: build_query(object_id: id) |> repo().delete_all() |> elem(1)


end
