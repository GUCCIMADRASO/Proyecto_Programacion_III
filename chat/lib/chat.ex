defmodule Chat do
  @moduledoc """
  API principal del sistema de chat distribuido.
  """

  # Aquí se expondrán las funciones de alto nivel para el cliente y pruebas

  def iniciar do
    Autenticacion.start_link()
    SupervisorChat.start_link(nil)
  end

  def iniciar_distribuido(nombre_nodo, cookie) do
    Node.start(String.to_atom(nombre_nodo), :shortnames)
    Node.set_cookie(String.to_atom(cookie))
    IO.puts("Nodo iniciado: #{nombre_nodo}")
  end

  def conectar_nodo(nombre_nodo) do
    case Node.connect(String.to_atom(nombre_nodo)) do
      true -> IO.puts("Conectado al nodo: #{nombre_nodo}")
      false -> IO.puts("No se pudo conectar al nodo: #{nombre_nodo}")
    end
  end
end

defmodule Chat.Application do
  use Application

  def start(_tipo, _args) do
    hijos = [
      {Registry, keys: :unique, name: RegistroSalaChat},
      {Registry, keys: :unique, name: RegistroSesionUsuario},
      {Phoenix.PubSub, name: Chat.PubSub},
      Supervisor.child_spec({Task, fn -> Autenticacion.start_link() end}, id: :autenticacion_task),
      Supervisor.child_spec({Task, fn -> ensure_sesion_usuario_registry() end}, id: :sesion_usuario_registry_task),
      SupervisorChat
    ]
    opciones = [strategy: :one_for_one, name: Chat.SupervisorPrincipal]
    Supervisor.start_link(hijos, opciones)
  end

  defp ensure_sesion_usuario_registry do
    # Ensure the Registry for SesionUsuario is properly initialized
    unless :ets.whereis(:tabla_autenticacion) != :undefined do
      :ets.new(:tabla_autenticacion, [:named_table, :public, :set])
    end
  end
end
