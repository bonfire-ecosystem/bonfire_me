defmodule Bonfire.Me.Identity.Mails do

  import Bamboo.Email
  import Bamboo.Phoenix

  alias Bonfire.Data.Identity.Account
  alias Pointers.Changesets
  alias Bonfire.Me.Web.EmailView
  alias Bonfire.Web.Router.Helpers, as: Routes

  def confirm_email(%Account{}=account) do
    IO.inspect(visit_url: Routes.confirm_email_path(Bonfire.Common.Config.get!(:endpoint_module), :show, account.email.confirm_token))
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
