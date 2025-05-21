defmodule ChatRoom do
  use GenServer

  # Estado: %{name: nombre, users: MapSet.new(), history: []}

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{name: name, users: MapSet.new(), history: []}, name: via_tuple(name))
  end

  defp via_tuple(name), do: {:via, Registry, {ChatRoomRegistry, name}}

  def init(state), do: {:ok, state}

  # API pública

  def add_user(room_name, user_id) do
    GenServer.call(via_tuple(room_name), {:add_user, user_id})
  end

  def remove_user(room_name, user_id) do
    GenServer.call(via_tuple(room_name), {:remove_user, user_id})
  end

  def send_message(room_name, user_id, message) do
    GenServer.call(via_tuple(room_name), {:send_message, user_id, message})
  end

  def user_in_room?(room_name, user_id) do
    GenServer.call(via_tuple(room_name), {:user_in_room?, user_id})
  end

  def get_history(room_name) do
    GenServer.call(via_tuple(room_name), :get_history)
  end

  # Callbacks

  def handle_call({:add_user, user_id}, _from, state) do
    users = MapSet.put(state.users, user_id)
    {:reply, :ok, %{state | users: users}}
  end

  def handle_call({:remove_user, user_id}, _from, state) do
    users = MapSet.delete(state.users, user_id)
    {:reply, :ok, %{state | users: users}}
  end

  def handle_call({:send_message, user_id, message}, _from, state) do
    msg = %{user: user_id, message: message, timestamp: :os.system_time(:second)}
    history = [msg | state.history]
    # Guardar en archivo plano
    File.write!("history_#{state.name}.txt", "#{inspect(msg)}\n", [:append])
    # Enviar a todos los usuarios (simulado)
    Enum.each(state.users, fn _uid -> :ok end)
    {:reply, :ok, %{state | history: history}}
  end

  def handle_call({:user_in_room?, user_id}, _from, state) do
    {:reply, MapSet.member?(state.users, user_id), state}
  end

  def handle_call(:get_history, _from, state) do
    {:reply, Enum.reverse(state.history), state}
  end
end
