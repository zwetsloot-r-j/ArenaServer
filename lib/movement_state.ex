defmodule ArenaServer.MovementState do

  use GenServer

  defstruct id: "0",
    x: 0,
    y: 0,
    rotation: 90,
    acceleration: 0,
    external_force_x: 0,
    external_force_y: 0,
    action_history: [],
    action_sync_status: %{version: 0}

  @movement_actions [
    "sync-battle",
    "set-start-position",
    "accelerate",
    "rotate",
    "apply-force"
  ]

  def start_link(id) do
    GenServer.start_link(__MODULE__, %ArenaServer.MovementState{id: id}, name: get_registration_by_id(id))
  end

  def get_registration_by_id(id) do
    {:global, "mov_" <> id}
  end

  def run_action(id, %{type: type} = action, user) do
    run_action(id, action, user, Enum.member?(@movement_actions, type))
  end

  def run_action(id, %{type: type} = action, user, true) do
    case GenServer.call(get_registration_by_id(id), {String.to_existing_atom(type), action, user}) do
      {:ok, response} ->
        response
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

  def handle_call(
    {:push_action, action, _user},
    _,
    %{action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    action_history = [action | action_history]
    new_version = action_sync_status.version + 1
    action_sync_status = action_sync_status
    |> Map.put(:version, new_version)

    {:reply, :ok, %{state | action_history: action_history, action_sync_status: action_sync_status}}
  end

  def handle_call(
    {:"sync-battle", _action, user},
    _,
    %{id: id, action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    user_sync_version = case action_sync_status[user] do
      nil -> 0
      version -> version
    end

    diff = action_sync_status.version - user_sync_version 
    action_sync_status = Map.put(action_sync_status, user, action_sync_status.version)
    {
      :reply,
      {:ok, [ArenaServer.Action.SyncMovement.sync_movement(id, action_sync_status.version) | Enum.take(action_history, diff)]}, 
      %{state | action_sync_status: action_sync_status}
    }
  end

  def handle_call(
    {:"set-start-position", %{payload: %{x: x, y: y, rotation: rotation}}, _user},
    _,
    state
  ) do
    state = %{state | x: x, y: y, rotation: rotation}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"accelerate", %{payload: %{acceleration: acceleration}}, _user},
    _,
    state
  ) do
    state = %{state | acceleration: acceleration}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"apply_force", %{payload: %{x: x, y: y}}, _user},
    _,
    state
  ) do
    state = %{state | external_force_x: x, external_force_y: y}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"rotate", %{payload: %{rotation: rotation}}, _user},
    _,
    state
  ) do
    state = %{state | rotation: rotation}
    {:reply, :push_action, state}
  end

end
