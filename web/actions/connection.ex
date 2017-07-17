defmodule ArenaServer.Action.Connection do

  defstruct type: "connection",
    payload: %{
      channel: "",
      user: "",
    }

  def join_battle() do
    battle_id = "1"
    user = "jan"
    join_battle(battle_id, user)
  end

  def join_battle(user) do
    payload = %{user: user}
    %ArenaServer.Action.Connection{payload: payload}
  end

  def join_battle(battle_id, user) when is_number(battle_id),
  do: join_battle(to_string(battle_id), user)

  def join_battle(battle_id, user) do
    payload = %{channel: "battle:" <> battle_id, user: user}
    %ArenaServer.Action.Connection{payload: payload}
  end

end
