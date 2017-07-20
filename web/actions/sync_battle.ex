defmodule ArenaServer.Action.SyncBattle do

  defstruct type: "sync-battle",
    payload: %{
      version: 0
    }

  def sync_battle() do
    %ArenaServer.Action.SyncBattle{}
  end

  def sync_battle(version) do
    %ArenaServer.Action.SyncBattle{payload: %{version: version}}
  end

end
