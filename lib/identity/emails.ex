defmodule Bonfire.Me.Identity.Emails do

  import Bamboo.Email
  import Bamboo.Phoenix
  alias Bonfire.Data.Identity.Account
  alias Pointers.Changesets
  alias Bonfire.Me.Web.EmailView

  def confirm_email(%Account{email: %{email_address: email}}=account) when is_binary(email) do
    conf =
      Bonfire.Common.Config.get_ext(:bonfire_me, __MODULE__, [])
      |> Keyword.get(:confirm_email, [])
    new_email()
    |> assign(:current_account, account)
    |> subject(Keyword.get(conf, :subject, "Confirm your email"))
    |> put_html_layout({EmailView, "confirm_email.html"})
    |> put_text_layout({EmailView, "confirm_email.text"})
  end

  def reset_password(%Account{email: %{email_address: email}}=account) when is_binary(email) do
    conf =
      Bonfire.Common.Config.get_ext(:bonfire_me, __MODULE__, [])
      |> Keyword.get(:reset_password_email, [])
    new_email()
    |> assign(:current_account, account)
    |> subject(Keyword.get(conf, :subject, "Reset your password"))
    |> put_html_layout({EmailView, "reset_password.html"})
    |> put_text_layout({EmailView, "reset_password.text"})
  end

end
