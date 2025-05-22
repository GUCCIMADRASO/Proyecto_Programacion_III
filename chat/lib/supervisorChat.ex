defmodule SupervisorChat do
  use Supervisor

  def iniciar_enlace(_arg_inicial) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    hijos = [
      {ServidorChat, []}
    ]
    Supervisor.init(hijos, strategy: :one_for_one)
  end
end
