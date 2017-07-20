defmodule ArenaServer.Action.CreateMovement do

  defstruct type: "create-movement"

  def create_movement() do
    %ArenaServer.Action.CreateMovement{}
  end

end
