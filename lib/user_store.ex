defmodule ArenaServer.UserStore do

  use GenServer

  defstruct users: %{}

  @user_actions [
    "create-user",
    "join-battle",
    "get-last-joined-battle"
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %ArenaServer.UserStore{}, name: __MODULE__)
  end

  def run_action(%{type: type} = action, user) do
    run_action(action, user, Enum.member?(@user_actions, type))
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
    {:"create-user", _action, user},
    _,
    %{users: users} = state
  ) do
    {:reply, :ok, %{state | users: Map.put(users, user, %{})}}
  end

  def handle_call(
    {:"join-battle", %{payload: %{battleId: battle_id}}, user},
    _,
    %{users: users} = state
  ) do
    user_data = users[user]
    |> Map.put(:battle, battle_id)
    {:reply, :ok, %{state | users: Map.put(users, user, user_data)}}
  end

  def handle_call({:"get-last-joined-battle", _action, user}, _, %{users: users} = state) do
    case users[user][:battle] do
      nil -> {:reply, {:error, :no_battle}, state}
      battle -> {:reply, {:ok, battle}, state}
    end
  end

end
