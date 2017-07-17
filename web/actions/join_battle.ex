defmodule ArenaServer.Action.JoinBattle do

  defstruct type: "join-battle",
    payload: %{
      battleId: "",
      user: "",
    }

  def join_battle(user) do
    payload = %{user: user}
    %ArenaServer.Action.JoinBattle{payload: payload}
  end

  def join_battle(battle_id, user) when is_number(battle_id),
  do: join_battle(to_string(battle_id), user)

  def join_battle(battle_id, user) do
    payload = %{battleId: battle_id, user: user}
    %ArenaServer.Action.JoinBattle{payload: payload}
  end

end
