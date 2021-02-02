defmodule Bonfire.Me.AccessControl.Acls do

  alias Bonfire.Data.AccessControl.Acl
  import Bonfire.Me.Integration

  def acls do
    %{ read_only:  "AC10N1YACCESS1SREADACCESS1"}
  end

  def create(%{}=attrs) when not is_struct(attrs) do
    repo().insert(changeset(attrs))
  end

  def changeset(access \\ %Acl{}, attrs) do
    Acl.changeset(access, attrs)
  end

end
