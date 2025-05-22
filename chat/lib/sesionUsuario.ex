defmodule SesionUsuario do
  use GenServer

  # Estado: %{usuario_id: id, sala: nil | nombre, pid: self()}

  def iniciar_enlace(usuario_id) do
    GenServer.start_link(__MODULE__, %{usuario_id: usuario_id, sala: nil, pid: self()}, name: tupla_via(usuario_id))
  end

  defp tupla_via(usuario_id), do: {:via, Registry, {RegistroSesionUsuario, usuario_id}}

  def init(estado), do: {:ok, estado}

  # API pública

  def unirse_sala(usuario_id, nombre_sala) do
    GenServer.call(tupla_via(usuario_id), {:unirse_sala, nombre_sala})
  end

  def salir_sala(usuario_id) do
    GenServer.call(tupla_via(usuario_id), :salir_sala)
  end

  def enviar_mensaje(usuario_id, mensaje) do
    GenServer.call(tupla_via(usuario_id), {:enviar_mensaje, mensaje})
  end

  def obtener_sala(usuario_id) do
    GenServer.call(tupla_via(usuario_id), :obtener_sala)
  end

  # Callbacks

  def handle_call({:unirse_sala, nombre_sala}, _from, estado) do
    {:reply, :ok, %{estado | sala: nombre_sala}}
  end

  def handle_call(:salir_sala, _from, estado) do
    {:reply, :ok, %{estado | sala: nil}}
  end

  def handle_call({:enviar_mensaje, mensaje}, _from, estado) do
    if estado.sala do
      SalaChat.enviar_mensaje(estado.sala, estado.usuario_id, mensaje)
      {:reply, :ok, estado}
    else
      {:reply, {:error, :no_en_sala}, estado}
    end
  end

  def handle_call(:obtener_sala, _from, estado) do
    {:reply, estado.sala, estado}
  end
end
