defmodule ArenaServer.Action.Message do

  defstruct type: "message",
    payload: %{
      message: %{
        body: "",
        displayTime: 2000
      }
    }

  def send_message(body) do
    message = %{body: body, displayTime: 2000}
    payload = %{message: message}
    %ArenaServer.Action.Message{payload: payload}
  end

  def send_message(body, display_time) do
    message = %{body: body, displayTime: display_time}
    payload = %{message: message}
    %ArenaServer.Action.Message{payload: payload}
  end

end
