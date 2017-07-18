defmodule ArenaServer.Action.JoinChannel do

  defstruct type: "join-channel",
    payload: %{
      channel: "",
      user: "",
    }

  def join_battle(user) do
    payload = %{user: user}
    %ArenaServer.Action.JoinChannel{payload: payload}
  end

  def join_battle(battle_id, user) when is_number(battle_id),
  do: join_battle(to_string(battle_id), user)

  def join_battle(battle_id, user) do
    payload = %{channel: "battle:" <> battle_id, user: user}
    %ArenaServer.Action.JoinChannel{payload: payload}
  end

end
