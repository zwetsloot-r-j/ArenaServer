defmodule ArenaServer.Action.SetStartPosition do

  defstruct type: "set-start-position",
    payload: %{
      movementId: "0",
      x: 0,
      y: 0,
      rotation: 0
    }

  def set_start_position(%{movementId: _, x: _, y: _, rotation: _} = payload) do
    %ArenaServer.Action.SetStartPosition{payload: payload}
  end

end
