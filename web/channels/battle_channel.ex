defmodule ArenaServer.BattleChannel do

  use Phoenix.Channel

  def join("battle:lobby", _parameters, socket) do
    send(self(), :on_join_lobby)
    {:ok, socket}
  end

  def join("battle:" <> _id, _parameters, socket) do
    send(self(), :on_join)
    {:ok, socket}
  end

  def handle_info(:on_join_lobby, %{assigns: %{user: user}} = socket) do
    action_list = ArenaServer.Action.JoinBattle.join_battle(user)
                  |> ArenaServer.MainState.run_action(user)
    push(socket, "actions", %{actionList: action_list})
    {:noreply, socket}
  end

  def handle_info(:on_join, %{assigns: %{user: user}} = socket) do
    action_list = with {:ok, battle_id} <- ArenaServer.Action.GetLastJoinedBattle.get_last_joined_battle()
      |> ArenaServer.UserStore.run_action(user)
    do
      ArenaServer.BattleState.run_action(battle_id, ArenaServer.Action.AddFighter.add_fighter(), user)
      battle_id
        |> ArenaServer.BattleState.run_action(
          ArenaServer.Action.Message.send_message("Player #{user} Joined"),
          user
        )

      ArenaServer.BattleState.run_action(battle_id, ArenaServer.Action.SyncBattle.sync_battle(), user)
    else
      _ -> [ArenaServer.Action.JoinChannel.join_lobby()]
    end

    IO.inspect(action_list)
    push(socket, "actions", %{actionList: action_list})

    {:noreply, socket}
  end

end
