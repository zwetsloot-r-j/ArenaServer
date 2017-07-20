defmodule ArenaServer.Action.AddFighter do

  defstruct type: "add-fighter",
    payload: %{
      movement_id: "0",
      player_id: "0",
      color: "green"
    }

  def add_fighter() do
    %ArenaServer.Action.AddFighter{}
  end

  def add_fighter(payload) do
    %ArenaServer.Action.AddFighter{payload: payload}
  end

end
