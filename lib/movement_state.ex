defmodule ArenaServer.MovementState do

  use GenServer

  defstruct id: "0",
    x: 0,
    y: 0,
    rotation: 90,
    acceleration: 0,
    externalForceX: 0,
    externalForceY: 0,
    action_history: [],
    action_sync_status: %{version: -1}

  @movement_actions [
    "sync-battle",
    "set-start-position",
    "accelerate",
    "rotate",
    "apply-force",
    "update-movement",
    "confirm-sync-movement",
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
    %{id: id, action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    new_version = action_sync_status.version + 1
    action_sync_status = action_sync_status
    |> Map.put(:version, new_version)

    action = Map.put(action, :serverId, ["movement" <> id, action_sync_status.version])
    action_history = [action | action_history]

    {:reply, :ok, %{state | action_history: action_history, action_sync_status: action_sync_status}}
  end

  def handle_call(
    {:"sync-battle", _action, user},
    _,
    %{id: id, action_history: action_history, action_sync_status: action_sync_status} = state
  ) do
    user_sync_version = case action_sync_status[user] do
      nil -> -1
      version -> version
    end

    diff = action_sync_status.version - user_sync_version 
    {
      :reply,
      {:ok, [
        ArenaServer.Action.SyncMovement.sync_movement(id, action_sync_status.version)
        | Enum.take(action_history, diff) |> Enum.reverse()
      ]}, 
      %{state | action_sync_status: action_sync_status}
    }
  end

  def handle_call(
    {:"confirm-sync-movement", %{payload: %{version: version}}, user},
    _,
    %{action_sync_status: action_sync_status} = state
  ) do
    action_sync_status = case action_sync_status[user] do
      nil -> Map.put(action_sync_status, user, version)
      previous_version when version > previous_version -> Map.put(action_sync_status, user, version)
      _ -> action_sync_status
    end

    {:reply, :ok, %{state | action_sync_status: action_sync_status}}
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
    {:"apply-force", %{payload: %{x: x, y: y}}, _user},
    _,
    state
  ) do
    state = %{state | external_force_x: x, external_force_y: y}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"update-movement", %{payload: %{rotation: rotation, acceleration: acceleration}}, _user},
    _,
    state
  ) do
    state = %{state | rotation: rotation, acceleration: acceleration}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"update-movement", %{payload: %{rotation: rotation}}, _user},
    _,
    state
  ) do
    state = %{state | rotation: rotation}
    {:reply, :push_action, state}
  end

  def handle_call(
    {:"update-movement", %{payload: %{acceleration: acceleration}}, _user},
    _,
    state
  ) do
    state = %{state | acceleration: acceleration}
    {:reply, :push_action, state}
  end

end
