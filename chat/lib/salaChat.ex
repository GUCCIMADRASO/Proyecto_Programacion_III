defmodule SalaChat do
  use GenServer

  # Estado: %{nombre: nombre, usuarios: MapSet.new(), historial: []}

  def iniciar_enlace(nombre) do
    GenServer.start_link(__MODULE__, %{nombre: nombre, usuarios: MapSet.new(), historial: []}, name: tupla_via(nombre))
  end

  defp tupla_via(nombre), do: {:via, Registry, {RegistroSalaChat, nombre}}

  def init(estado), do: {:ok, estado}

  # API pública

  def agregar_usuario(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:agregar_usuario, usuario_id})
  end

  def eliminar_usuario(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:eliminar_usuario, usuario_id})
  end

  def enviar_mensaje(nombre_sala, usuario_id, mensaje) do
    GenServer.call(tupla_via(nombre_sala), {:enviar_mensaje, usuario_id, mensaje})
  end

  def usuario_en_sala?(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:usuario_en_sala?, usuario_id})
  end

  def obtener_historial(nombre_sala) do
    GenServer.call(tupla_via(nombre_sala), :obtener_historial)
  end

  # Callbacks

  def handle_call({:agregar_usuario, usuario_id}, _from, estado) do
    usuarios = MapSet.put(estado.usuarios, usuario_id)
    {:reply, :ok, %{estado | usuarios: usuarios}}
  end

  def handle_call({:eliminar_usuario, usuario_id}, _from, estado) do
    usuarios = MapSet.delete(estado.usuarios, usuario_id)
    {:reply, :ok, %{estado | usuarios: usuarios}}
  end

  def handle_call({:enviar_mensaje, usuario_id, mensaje}, _from, estado) do
    msg = %{usuario: usuario_id, mensaje: mensaje, marca_tiempo: :os.system_time(:second)}
    historial = [msg | estado.historial]
    # Guardar en archivo plano
    File.write!("historial_#{estado.nombre}.txt", "#{inspect(msg)}\n", [:append])
    # Enviar a todos los usuarios (simulado)
    Enum.each(estado.usuarios, fn _uid -> :ok end)
    {:reply, :ok, %{estado | historial: historial}}
  end

  def handle_call({:usuario_en_sala?, usuario_id}, _from, estado) do
    {:reply, MapSet.member?(estado.usuarios, usuario_id), estado}
  end

  def handle_call(:obtener_historial, _from, estado) do
    {:reply, Enum.reverse(estado.historial), estado}
  end
end
