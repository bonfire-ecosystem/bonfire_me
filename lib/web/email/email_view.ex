defmodule Bonfire.Me.Web.EmailView do
  use Bonfire.WebPhoenix, [:view, Application.get_env(:bonfire_me, :templates_path)]
end
