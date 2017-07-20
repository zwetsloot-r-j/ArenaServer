defmodule ArenaServer.MovementSupervisor do

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_movement(id) do
    Supervisor.start_child(__MODULE__, [id])
  end

  def init(:ok) do
    children = [
      worker(ArenaServer.MovementState, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

end
