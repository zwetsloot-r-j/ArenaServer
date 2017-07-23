defmodule ArenaServer.MainState do

  use GenServer

  defstruct battle: %{
      last_id: 0,
    },
    users: %{
      last_id: 0,
    },
    movements: %{
      last_id: 0
    }

  @main_actions [
    "join-battle",
    "create-user",
    "create-movement"
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %ArenaServer.MainState{}, name: __MODULE__)
  end

  def run_action(action),
  do: run_action(action, nil)

  def run_action(%{type: type} = action, user) do
    run_action(action, user, Enum.member?(@main_actions, type))
  end

  def run_action(%{type: type} = action, user, true) do
    GenServer.call(__MODULE__, {String.to_existing_atom(type), action, user})
  end 

  def run_action(_, _, false),
  do: {:error, :invalid_type}

  def init(state) do
    {:ok, state}
  end

  def handle_call(
    {:"join-battle", action, user},
    _,
    %{battle: %{last_id: last_id}} = state
  ) do
    battle_id = to_string(last_id)
    get_last_battle(state)
    |> ArenaServer.BattleState.run_action(ArenaServer.Action.AddPlayer.add_player(user), user)
    |> case() do
      {:error, :battle_is_full} ->
        state = %{state | battle: %{state.battle | last_id: last_id + 1}}
        handle_call({:"join-battle", action, user}, nil, state)
      _ ->
        join_battle_action = ArenaServer.Action.JoinBattle.join_battle(battle_id, user)
        join_battle_action |> ArenaServer.UserStore.run_action(user)
        {:reply, [
          join_battle_action,
          ArenaServer.Action.JoinChannel.join_battle(battle_id)
        ], state}
    end
  end

  def handle_call(
    {:"create-user", action, _},
    _,
    %{users: %{last_id: last_id}} = state
  ) do
    user = to_string(last_id)
    ArenaServer.UserStore.run_action(action, user)
    {:reply, user, %{state | users: %{last_id: last_id + 1}}}
  end

  def handle_call(
    {:"create-movement", _, _},
    _,
    %{movements: %{last_id: last_id}} = state
  ) do
    movement_id = to_string(last_id)
    ArenaServer.MovementSupervisor.add_movement(movement_id)
    {:reply, movement_id, %{state | movements: %{last_id: last_id + 1}}}
  end

  defp get_last_battle(%{battle: %{last_id: last_id}}) do
    case GenServer.whereis(ArenaServer.BattleState.get_registration_by_id(to_string(last_id))) do
      nil ->
        {:ok, _pid} = ArenaServer.BattleSupervisor.start_battle(to_string(last_id))
        to_string(last_id)
      _ ->
        to_string(last_id)
    end
  end

end
