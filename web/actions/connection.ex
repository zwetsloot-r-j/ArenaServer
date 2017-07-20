defmodule ArenaServer.Action.JoinChannel do

  defstruct type: "join-channel",
    payload: %{
      channel: "",
    }

  def join_lobby() do
    payload = %{channel: "battle:lobby"}
    %ArenaServer.Action.JoinChannel{payload: payload}
  end

  def join_battle(battle_id) when is_number(battle_id),
  do: join_battle(to_string(battle_id))

  def join_battle(battle_id) do
    payload = %{channel: "battle:" <> battle_id}
    %ArenaServer.Action.JoinChannel{payload: payload}
  end

end
