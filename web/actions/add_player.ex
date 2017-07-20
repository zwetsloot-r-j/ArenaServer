defmodule ArenaServer.Action.AddPlayer do

  defstruct type: "add-player",
    payload: %{
      player: %{
        id: 0
      }
    }

  def add_player() do
    %ArenaServer.Action.AddPlayer{}
  end

  def add_player(id) do
    %ArenaServer.Action.AddPlayer{payload: %{player: %{id: id}}}
  end

end
