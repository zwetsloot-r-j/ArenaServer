defmodule ArenaServer.BattleState do

  use GenServer

  defstruct id: 0,
    action_history: [],
    players: %{},
    fighters: %{},
    projectiles: %{}

  @battle_actions [
    "add-player",
    "message",
  ]

  @max_player_count 2

  def start_link(id) do
    GenServer.start_link(__MODULE__, %ArenaServer.BattleState{id: id}, name: get_registration_by_id(id))
  end

  def run_action(id, %{type: type} = action) do
    run_action(id, action, Enum.member?(@battle_actions, type))
  end

  def run_action(id, %{type: type} = action, true) do
    case GenServer.call(get_registration_by_id(id), {String.to_existing_atom(type), action}) do
      :ok ->
        GenServer.call({:global, id}, {:push_action, action})
      error ->
        error
    end
  end 

  def run_action(_, _, false),
  do: {:error, :invalid_type}

  def init(state) do
    {:ok, state}
  end

  def get_registration_by_id(id) do
    {:global, id}
  end

  def handle_call({:push_action, action}, _, %{action_history: action_history} = state) do
    action_history = [action | action_history]
    {:reply, action_history, Map.put(state, :action_history, action_history)}
  end

  def handle_call({:"add-player", %{payload: %{id: player_id}}}, _, state) do
    case is_full?(state) do
      true ->
        {:reply, {:error, :battle_is_full}, state}
      false ->
        state = state
        |> Map.put(:players, Map.put(state.players, player_id, %{}))
        |> Map.put(:fighters, Map.put(state.fighters, player_id, %{}))
        {:reply, :ok, state}
    end
  end

  def handle_call({:"message", _}, state),
  do: {:reply, :ok, state}

  defp is_full?(%{players: players}) do
    Enum.count(players) >= @max_player_count
  end

end
