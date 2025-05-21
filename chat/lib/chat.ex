defmodule Chat do
  @moduledoc """
  API principal del sistema de chat distribuido.
  """

  # Aquí se expondrán las funciones de alto nivel para el cliente y pruebas

  def start do
    Auth.start_link()
    ChatSupervisor.start_link(nil)
  end
end

defmodule Chat.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ChatRoomRegistry},
      {Registry, keys: :unique, name: UserSessionRegistry},
      {Task, fn -> Auth.start_link() end},
      ChatSupervisor
    ]
    opts = [strategy: :one_for_one, name: Chat.MainSupervisor]
    Supervisor.start_link(children, opts)
  end
end
