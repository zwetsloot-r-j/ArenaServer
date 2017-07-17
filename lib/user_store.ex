defmodule ArenaServer.UserStore do

  use GenServer

  defstruct users: %{}

  @user_actions [
    "create-user"
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %ArenaServer.UserStore{}, name: __MODULE__)
  end

  def run_action(%{type: type} = action) do
    run_action(action, Enum.member?(@user_actions, type))
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
    {:"create-user", %{payload: %{user: user_id}}},
    _,
    %{users: users} = state
  ) do
    {:reply, [], %{state | users: Map.put(users, user_id, %{})}}
  end

end
