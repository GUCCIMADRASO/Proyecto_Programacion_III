defmodule SupervisorChat do
  use Supervisor

  def start_link(_arg_inicial) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    hijos = [
      {ServidorChat, []}
    ]

    # Configuración para nodos distribuidos
    :global.register_name(:servidor_chat, self())

    Supervisor.init(hijos, strategy: :one_for_one)
  end
end
