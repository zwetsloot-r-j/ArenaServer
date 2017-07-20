defmodule ArenaServer.Action.SetStartPosition do

  defstruct type: "set-start-position",
    payload: %{
      movement_id: "0",
      x: 0,
      y: 0,
      rotation: 0
    }

  def set_start_position(%{movement_id: _, x: _, y: _, rotation: _} = payload) do
    %ArenaServer.Action.SetStartPosition{payload: payload}
  end

end
