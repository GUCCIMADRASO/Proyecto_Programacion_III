defmodule SalaChat do
  use GenServer

  # Estado: %{nombre: nombre, usuarios: MapSet.new(), historial: []}

  def start_link(nombre) do
    GenServer.start_link(__MODULE__, %{nombre: nombre, usuarios: MapSet.new(), historial: []}, name: tupla_via(nombre))
  end

  defp tupla_via(nombre), do: {:via, Registry, {RegistroSalaChat, nombre}}

  def init(estado) do
    # Suscribirse al canal de la sala
    Phoenix.PubSub.subscribe(Chat.PubSub, "sala:#{estado.nombre}")
    {:ok, estado}
  end

  # API pública

  def agregar_usuario(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:agregar_usuario, usuario_id})
  end

  def eliminar_usuario(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:eliminar_usuario, usuario_id})
  end

  def enviar_mensaje(nombre_sala, usuario_id, mensaje) do
    # Publicar el mensaje en el canal de la sala
    Phoenix.PubSub.broadcast(Chat.PubSub, "sala:#{nombre_sala}", {usuario_id, mensaje})
    GenServer.call(tupla_via(nombre_sala), {:enviar_mensaje, usuario_id, mensaje})
  end

  def usuario_en_sala?(nombre_sala, usuario_id) do
    GenServer.call(tupla_via(nombre_sala), {:usuario_en_sala?, usuario_id})
  end

  def obtener_historial(nombre_sala) do
    GenServer.call(tupla_via(nombre_sala), :obtener_historial)
  end

  def buscar_en_historial(nombre_sala, termino) do
    # Leer el archivo de historial de la sala
    archivo = "historial_#{nombre_sala}.txt"
    if File.exists?(archivo) do
      File.stream!(archivo)
      |> Enum.filter(fn linea -> String.contains?(linea, termino) end)
      |> Enum.map(&String.trim/1)
    else
      {:error, :archivo_no_encontrado}
    end
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

  def handle_info({usuario_id, mensaje}, estado) do
    IO.puts("Nuevo mensaje en sala #{estado.nombre} de #{usuario_id}: #{mensaje}")
    {:noreply, estado}
  end
end
