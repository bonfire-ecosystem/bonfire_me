defmodule Bonfire.Me.Web.ConfirmEmailController.Test do

  use Bonfire.Me.ConnCase
  alias Bonfire.Me.Fake

  describe "request" do

    test "must be a guest" do
    end

    test "form renders" do
      conn = conn()
      conn = get(conn, "/confirm-email")
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
    end

    test "absence validation" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{})
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "can't be blank" == Floki.text(err)
    end

    test "format validation" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{"confirm_email_fields" => %{"email" => Faker.Pokemon.name()}})
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [] = Floki.find(doc, ".error")
      assert [err] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='confirm-email-form_email']")
      assert "has invalid format" == Floki.text(err)
    end

    test "not found" do
      conn = conn()
      conn = post(conn, "/confirm-email", %{"confirm_email_fields" => %{"email" => Fake.email()}})
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
    end

    # TODO
    # test "expired" do
    #   conn = conn()
    # end

    test "success" do
      conn = conn()
      account = fake_account!()
      conn = get(conn, "/confirm-email")
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      conn = post(recycle(conn), "/confirm-email", %{"confirm_email_fields" => %{"email" => account.email.email_address}})
      doc = floki_response(conn)
      assert [] = Floki.find(doc, "#confirm-email-form")
      assert [conf] = Floki.find(doc, ".form__confirmation")
      assert Floki.text(conf) =~ ~r/emailed you/
    end

  end

  describe "confirmation" do

    test "must be a guest" do
      # TODO
    end

    test "not found" do
      conn = conn()
      conn = get(conn, "/confirm-email/#{Fake.confirm_token()}")
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end

    test "success" do
      conn = conn()
      account = fake_account!()
      conn = get(conn, "/confirm-email/#{account.email.confirm_token}")
      assert redirected_to(conn) == "/create-user"
    end

    test "cannot confirm twice" do
      conn = conn()
      account = fake_account!()
      conn = get(conn, "/confirm-email/#{account.email.confirm_token}")
      assert redirected_to(conn) == "/create-user"
      conn = get(build_conn(), "/confirm-email/#{account.email.confirm_token}")
      doc = floki_response(conn)
      assert [view] = Floki.find(doc, "#confirm_email")
      assert [form] = Floki.find(view, "form")
      assert [_] = Floki.find(form, "input[type='email']")
      assert [_] = Floki.find(form, "button[type='submit']")
      assert [err] = Floki.find(doc, ".error")
      assert Floki.text(err) =~ ~r/invalid confirmation link/i
    end
  end

end
