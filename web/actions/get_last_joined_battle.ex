defmodule ArenaServer.Action.GetLastJoinedBattle do

  defstruct type: "get-last-joined-battle"

  def get_last_joined_battle() do
    %ArenaServer.Action.GetLastJoinedBattle{}
  end

end
