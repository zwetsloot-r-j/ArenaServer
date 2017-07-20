defmodule ArenaServer.Action.SyncMovement do

  defstruct type: "sync-movement",
    payload: %{
      id: "0",
      version: 0
    }

  def sync_movement(id, version) do
    %ArenaServer.Action.SyncMovement{payload: %{id: id, version: version}}
  end

end
