defmodule ArenaServer.BattleState do

  use GenServer

  defstruct id: "0",
    action_history: [],
    action_sync_status: %{version: 0},
    players: %{},
    fighters: %{},
    projectiles: %{}

  @battle_actions [
    "add-player",
    "add-fighter",
    "message",
    "sync-battle",
    "update-movement",
  ]

  @max_player_count 2

  def start_link(id) do
    GenServer.start_link(__MODULE__, %ArenaServer.BattleState{id: id}, name: get_registration_by_id(id))
  end

  def run_action(id, %{type: type} = action, user) do
    run_action(id, action, user, Enum.member?(@battle_actions, type))
  end

  def run_action(id, %{type: type} = action, user, true) do
    case GenServer.call(get_registration_by_id(id), {String.to_existing_atom(type), action, user}) do
      {:ok, response} ->
        response
      {:push_action, %{type: ^type} = action} ->
        GenServer.call(get_registration_by_id(id), {:push_action, action, user})
      {:push_action, response} ->
        GenServer.call(get_registration_by_id(id), {:push_action, action, user})
        response
      :push_action ->
        GenServer.call(get_registration_by_id(id), {:push_action, action, user})
      error ->
        error
    end
  end 

  def run_action(_, _, _, false),
  do: {:error, :invalid_type}

  def init(state) do
    {:ok, state}
  end

  def get_registration_by_id(id) do
    {:global, id}
  end

  def handle_call(
    {:push_action, action, _user},
    _,
    %{action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    action = Map.put(action, :serverId, ["battle", action_sync_status.version])
    action_history = [action | action_history]
    new_version = action_sync_status.version + 1
    action_sync_status = action_sync_status
    |> Map.put(:version, new_version)

    {:reply, :ok, %{state | action_history: action_history, action_sync_status: action_sync_status}}
  end

  def handle_call({:"add-player", _action, user}, _, state) do
    case is_full?(state) do
      true ->
        {:reply, {:error, :battle_is_full}, state}
      false ->
        state = state
        |> Map.put(:players, Map.put(state.players, user, %{}))
        |> Map.put(:action_sync_status, Map.put(state.action_sync_status, user, 0))
        {:reply, :push_action, state}
    end
  end

  def handle_call({:"add-fighter", action, user}, _, %{fighters: fighters} =  state) do
    fighter_number = Enum.count(fighters)
    fighter = ArenaServer.FighterState.initialize_player_fighter(user, fighter_number)
    state = Map.put(state, :fighters, Map.put(state.fighters, user, fighter))
    {:reply, {:push_action, %{action | payload: fighter}}, state}
  end

  def handle_call({:"message", _action, _user}, _, state),
  do: {:reply, :push_action, state}

  def handle_call(
    {:"sync-battle", action, user},
    _,
    %{action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    diff = action_sync_status.version - action_sync_status[user]
    # action_sync_status = Map.put(action_sync_status, user, action_sync_status.version)
    action_history = action_history
      |> Enum.take(diff)
      |> (fn(action_history) -> [ArenaServer.Action.SyncBattle.sync_battle(action_sync_status.version) | action_history] end).()
      |> Kernel.++(sync_fighters(user, action, state))
    {
      :reply,
      {:ok, action_history}, 
      %{state | action_sync_status: action_sync_status}
    }
  end

  def handle_call(
    {:"update-movement", %{payload: %{movementId: movement_id}} = action, user},
    _,
    state
  ) do
    ArenaServer.MovementState.run_action(movement_id, action, user)
    {:reply, :ok, state}
  end

  defp sync_fighters(user, action, %{fighters: fighters}) do
    fighters
    |> Enum.reduce([], fn
      {_, %{movementId: movement_id}}, action_history ->
        ArenaServer.MovementState.run_action(movement_id, action, user) ++ action_history
    end)
  end

  defp is_full?(%{players: players}) do
    Enum.count(players) >= @max_player_count
  end

end
