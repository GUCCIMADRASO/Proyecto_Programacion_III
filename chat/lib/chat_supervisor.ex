defmodule ChatSupervisor do
  use Supervisor

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {ChatServer, []}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
