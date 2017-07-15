defmodule ArenaServer.BattleChannel do

  use Phoenix.Channel

  def join("battle:lobby", _, socket) do
    send(self, :on_join)
    {:ok, socket}
  end

  def handle_info(:on_join, socket) do
    broadcast!(socket, "action", %{
      type: "message",
      payload: %{
        body: "hi lol",
        displayTime: 2000,
      }
    })
    {:noreply, socket}
  end

end
