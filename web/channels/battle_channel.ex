defmodule ArenaServer.BattleChannel do

  use Phoenix.Channel

  intercept ["actions"]

  def join("battle:lobby", _parameters, socket) do
    send(self(), :on_join_lobby)
    {:ok, socket}
  end

  def join("battle:" <> _id, _parameters, socket) do
    send(self(), :on_join)
    {:ok, socket}
  end

  def handle_in("action", action, %{assigns: %{user: user}} = socket) do
    # TODO find a more performance friendly way to get the battle id
    {:ok, battle_id} = ArenaServer.UserStore.run_action(ArenaServer.Action.GetLastJoinedBattle.get_last_joined_battle(), user)
    ArenaServer.BattleState.run_action(battle_id, action, user)
    broadcast!(socket, "actions", %{battleId: battle_id})

    {:noreply, socket}
  end

  def handle_out("actions", %{battleId: battle_id}, %{assigns: %{user: user}} = socket) do
    action_list = ArenaServer.BattleState.run_action(battle_id, ArenaServer.Action.SyncBattle.sync_battle(), user)
    push(socket, "actions", %{actionList: action_list})

    {:noreply, socket}
  end

  def handle_info(:on_join_lobby, %{assigns: %{user: user}} = socket) do
    action_list = ArenaServer.Action.JoinBattle.join_battle()
                  |> ArenaServer.MainState.run_action(user)

    IO.inspect("ON JOIN LOBBY")
    IO.inspect(action_list)
    IO.puts("________")
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

    IO.inspect("ON JOIN BATTLE")
    IO.inspect(action_list)
    IO.inspect("________")
    push(socket, "actions", %{actionList: action_list})

    {:noreply, socket}
  end

end
