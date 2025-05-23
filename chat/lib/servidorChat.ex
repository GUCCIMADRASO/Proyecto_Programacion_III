defmodule ServidorChat do
  use GenServer

  # Estado: %{usuarios: %{usuario_id => pid}, salas: %{nombre_sala => pid}, socket: nil}

  def start_link(opciones) do
    GenServer.start_link(__MODULE__, %{usuarios: %{}, salas: %{}, socket: nil}, Keyword.merge(opciones, [name: __MODULE__]))
  end

  def init(estado) do
    {:ok, socket} = :gen_tcp.listen(4000, [:binary, packet: :line, active: false, reuseaddr: true])
    spawn(fn -> aceptar_conexiones(socket) end)
    {:ok, %{estado | socket: socket}}
  end

  defp aceptar_conexiones(socket) do
    {:ok, cliente} = :gen_tcp.accept(socket)
    spawn(fn -> manejar_cliente(cliente) end)
    aceptar_conexiones(socket)
  end

  defp manejar_cliente(cliente) do
    case :gen_tcp.recv(cliente, 0) do
      {:ok, mensaje} ->
        IO.puts("Mensaje recibido: #{mensaje}")
        :gen_tcp.send(cliente, "Mensaje recibido\n")
        manejar_cliente(cliente)
      {:error, :closed} ->
        IO.puts("Cliente desconectado")
    end
  end

  # API pública

  def registrar_usuario(usuario_id, contrasena) do
    GenServer.call(__MODULE__, {:registrar_usuario, usuario_id, contrasena})
  end

  def listar_usuarios do
    GenServer.call(__MODULE__, :listar_usuarios)
  end

  def crear_sala(nombre_sala) do
    GenServer.call(__MODULE__, {:crear_sala, nombre_sala})
  end

  def unirse_sala(usuario_id, nombre_sala) do
    GenServer.call(__MODULE__, {:unirse_sala, usuario_id, nombre_sala})
  end

  def salir_sala(usuario_id) do
    GenServer.call(__MODULE__, {:salir_sala, usuario_id})
  end

  def enviar_mensaje(usuario_id, mensaje) do
    GenServer.call(__MODULE__, {:enviar_mensaje, usuario_id, mensaje})
  end

  def obtener_historial(nombre_sala) do
    GenServer.call(__MODULE__, {:obtener_historial, nombre_sala})
  end

  # Callbacks

  def handle_call({:registrar_usuario, usuario_id, contrasena}, _from, estado) do
    case Map.has_key?(estado.usuarios, usuario_id) do
      true -> {:reply, {:error, :usuario_existe}, estado}
      false ->
        {:ok, _pid} = SesionUsuario.start_link(usuario_id)
        Autenticacion.registrar(usuario_id, contrasena)
        usuarios = Map.put(estado.usuarios, usuario_id, self())
        {:reply, :ok, %{estado | usuarios: usuarios}}
    end
  end

  def handle_call(:listar_usuarios, _from, estado) do
    # Filtrar usuarios conectados en tiempo real
    usuarios_conectados = Enum.filter(Map.keys(estado.usuarios), fn usuario_id ->
      Process.alive?(Map.get(estado.usuarios, usuario_id))
    end)
    {:reply, usuarios_conectados, estado}
  end

  def handle_call({:crear_sala, nombre_sala}, _from, estado) do
    case Map.has_key?(estado.salas, nombre_sala) do
      true -> {:reply, {:error, :sala_existe}, estado}
      false ->
        {:ok, _pid} = SalaChat.start_link(nombre_sala)
        salas = Map.put(estado.salas, nombre_sala, self())
        {:reply, :ok, %{estado | salas: salas}}
    end
  end

  def handle_call({:unirse_sala, usuario_id, nombre_sala}, _from, estado) do
    if Map.has_key?(estado.salas, nombre_sala) and Map.has_key?(estado.usuarios, usuario_id) do
      SalaChat.agregar_usuario(nombre_sala, usuario_id)
      SesionUsuario.unirse_sala(usuario_id, nombre_sala)
      Phoenix.PubSub.broadcast(Chat.PubSub, "sala:#{nombre_sala}", {:usuario_unido, usuario_id})
      {:reply, :ok, estado}
    else
      {:reply, {:error, :no_encontrado}, estado}
    end
  end

  def handle_call({:salir_sala, usuario_id}, _from, estado) do
    Enum.each(estado.salas, fn {sala, _pid} ->
      SalaChat.eliminar_usuario(sala, usuario_id)
      Phoenix.PubSub.broadcast(Chat.PubSub, "sala:#{sala}", {:usuario_salio, usuario_id})
    end)
    {:reply, :ok, estado}
  end

  def handle_call({:enviar_mensaje, usuario_id, mensaje}, _from, estado) do
    # Buscar la sala del usuario
    sala = Enum.find_value(estado.salas, fn {sala, _pid} ->
      if SalaChat.usuario_en_sala?(sala, usuario_id), do: sala, else: nil
    end)
    if sala do
      SalaChat.enviar_mensaje(sala, usuario_id, mensaje)
      {:reply, :ok, estado}
    else
      {:reply, {:error, :no_en_sala}, estado}
    end
  end

  def handle_call({:obtener_historial, nombre_sala}, _from, estado) do
    if Map.has_key?(estado.salas, nombre_sala) do
      historial = SalaChat.obtener_historial(nombre_sala)
      {:reply, historial, estado}
    else
      {:reply, {:error, :no_encontrado}, estado}
    end
  end
end
