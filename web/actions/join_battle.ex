defmodule ArenaServer.Action.JoinBattle do

  defstruct type: "join-battle",
    payload: %{
      battleId: "",
      user: ""
    }

  def join_battle(),
  do: join_battle("")

  def join_battle(battle_id) when is_number(battle_id),
  do: join_battle(to_string(battle_id))

  def join_battle(battle_id), 
  do: join_battle(battle_id, "")

  def join_battle(battle_id, user) do
    payload = %{battleId: battle_id, user: user}
    %ArenaServer.Action.JoinBattle{payload: payload}
  end

end
