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

  def handle_info(:on_join_lobby, socket) do
    user = socket.assigns.user
    action_list = ArenaServer.MainState.run_action(ArenaServer.Action.JoinBattle.join_battle(user))
    push(socket, "actions", %{actionList: action_list})
    {:noreply, socket}
  end

  def handle_info(:on_join, socket) do
    IO.puts("HANDLE ON JOIN")
    IO.inspect(socket.assigns)
    broadcast!(socket, "actions", %{actionList: [ArenaServer.Action.Message.send_message("Player Joined")]})
    {:noreply, socket}
  end

end
