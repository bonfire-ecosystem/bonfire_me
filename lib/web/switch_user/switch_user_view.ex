defmodule Bonfire.Me.Web.SwitchUserView do
  use Bonfire.Web,
    view: [root: Application.get_env(:bonfire_me, :templates_path)]
end
