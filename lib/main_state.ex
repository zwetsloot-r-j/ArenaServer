defmodule ArenaServer.MainState do

  use GenServer

  defstruct battle: %{
      last_id: 0,
    },
    users: %{
      last_id: 0,
    }

  @main_actions [
    "join-battle",
    "create-user",
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %ArenaServer.MainState{}, name: __MODULE__)
  end

  def run_action(%{type: type} = action) do
    run_action(action, Enum.member?(@main_actions, type))
  end

  def run_action(%{type: type} = action, true) do
    GenServer.call(__MODULE__, {String.to_existing_atom(type), action})
  end 

  def run_action(_, false),
  do: {:error, :invalid_type}

  def init(state) do
    {:ok, state}
  end

  def handle_call(
    {:"join-battle", %{payload: %{user: player_id}} = action},
    _,
    %{battle: %{last_id: last_id}} = state
  ) do
    get_last_battle(state)
    |> ArenaServer.BattleState.run_action(ArenaServer.Action.AddPlayer.add_player(player_id))
    |> case() do
      {:error, :battle_is_full} ->
        state = %{state | battle: %{state.battle | last_id: last_id + 1}}
        handle_call({:connection, action}, nil, state)
      _ ->
        {:reply, [
          ArenaServer.Action.JoinBattle.join_battle(last_id, player_id),
          ArenaServer.Action.Connection.join_battle(last_id, player_id)
        ], state}
    end
  end

  def handle_call(
    {:"create-user", action},
    _,
    %{users: %{last_id: last_id}} = state
  ) do
    user = to_string(last_id)
    action = %{action | payload: %{user: user}}
    ArenaServer.UserStore.run_action(action)
    {:reply, user, %{state | users: %{last_id: last_id + 1}}}
  end

  defp get_last_battle(%{battle: %{last_id: last_id}}) do
    case GenServer.whereis(ArenaServer.BattleState.get_registration_by_id(last_id)) do
      nil ->
        {:ok, _pid} = ArenaServer.BattleSupervisor.start_battle(last_id)
        last_id
      _ ->
        last_id
    end
  end

end
