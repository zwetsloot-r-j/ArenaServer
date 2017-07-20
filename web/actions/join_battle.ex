defmodule ArenaServer.Action.JoinBattle do

  defstruct type: "join-battle",
    payload: %{
      battleId: "",
    }

  def join_battle(battle_id) when is_number(battle_id),
  do: join_battle(to_string(battle_id))

  def join_battle(battle_id) do
    payload = %{battleId: battle_id}
    %ArenaServer.Action.JoinBattle{payload: payload}
  end

end
