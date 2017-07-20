defmodule ArenaServer.FighterState do

  defstruct id: "0",
    color: "green",
    movement_id: "0",
    player_id: "0"

  @player_1_start_data %{
    color: "green",
    movement: %{
      x: 200,
      y: 320,
      rotation: 90
    }
  }

  @player_2_start_data %{
    color: "red",
    movement: %{
      x: 760,
      y: 320,
      rotation: 270
    }
  }

  def initialize_player_fighter(user, 0) do
    initialize_player_fighter(user, @player_1_start_data)
  end

  def initialize_player_fighter(user, 1) do
    initialize_player_fighter(user, @player_2_start_data)
  end

  def initialize_player_fighter(user, %{movement: movement} = start_data) do
    create_movement_action = ArenaServer.Action.CreateMovement.create_movement()
    movement_id = ArenaServer.MainState.run_action(create_movement_action, user)
    set_start_position_action = ArenaServer.Action.SetStartPosition.set_start_position(Map.put(movement, :movement_id, movement_id))
    :ok = ArenaServer.MovementState.run_action(movement_id, set_start_position_action, user)
    %ArenaServer.FighterState{
      id: user,
      color: start_data.color,
      movement_id: movement_id,
      player_id: user
    }
  end

end
