defmodule Bonfire.Me.Web.CreateUserController do
  use Phoenix.Controller, :controller
  alias CommonsPub.Users.User
  alias Bonfire.Me.Web.Plugs.MustLogIn
  alias Bonfire.Me.Users

  def index(conn, _),
    do: render(conn, "form.html", form: form(conn.assigns[:account]))

  def create(conn, params) do
    Map.get(params, "create_form", %{})
    |> Users.create(conn.assigns[:account])
    |> case do
      {:ok, user} -> switched(conn, user)
      {:error, form} ->
         render(conn, "form.html", form: form)
    end
  end

  defp form(attrs \\ %{}, account), do: Users.changeset(:create, attrs, account)

  defp switched(conn, %User{id: id, character: %{username: username}}) do
    conn
    |> put_flash(:info, "Welcome, #{username}, you're all ready to go!")
    |> put_session(:user_id, id)
    |> redirect(to: "/_/@#{username}")
  end

end
