defmodule Chat do
  @moduledoc """
  API principal del sistema de chat distribuido.
  """

  # Aquí se expondrán las funciones de alto nivel para el cliente y pruebas

  def iniciar do
    Autenticacion.iniciar_enlace()
    SupervisorChat.iniciar_enlace(nil)
  end
end

defmodule Chat.Aplicacion do
  use Application

  def start(_tipo, _args) do
    hijos = [
      {Registry, keys: :unique, name: RegistroSalaChat},
      {Registry, keys: :unique, name: RegistroSesionUsuario},
      {Task, fn -> Autenticacion.iniciar_enlace() end},
      SupervisorChat
    ]
    opciones = [strategy: :one_for_one, name: Chat.SupervisorPrincipal]
    Supervisor.start_link(hijos, opciones)
  end
end
