defmodule ArenaServer.Action.AddFighter do

  defstruct type: "add-fighter",
    payload: %{
      movementId: "0",
      playerId: "0",
      color: "green"
    }

  def add_fighter() do
    %ArenaServer.Action.AddFighter{}
  end

  def add_fighter(payload) do
    %ArenaServer.Action.AddFighter{payload: payload}
  end

end
