defmodule ArenaServer.Action.AddPlayer do

  defstruct type: "add-player",
    payload: %{
      id: 0
    }

  def add_player(player_id) do
    payload = %{id: player_id}
    %ArenaServer.Action.AddPlayer{payload: payload}
  end

end
