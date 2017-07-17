defmodule ArenaServer.Action.CreateUser do

  defstruct type: "create-user",
    payload: %{
      user: ""
    }

  def create_user() do
    %ArenaServer.Action.CreateUser{}
  end

  def create_user(user) do
    payload = %{user: user}
    %ArenaServer.Action.CreateUser{payload: payload}
  end

end
