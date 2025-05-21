defmodule UserSession do
  use GenServer

  # Estado: %{user_id: id, room: nil | nombre, pid: self()}

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, %{user_id: user_id, room: nil, pid: self()}, name: via_tuple(user_id))
  end

  defp via_tuple(user_id), do: {:via, Registry, {UserSessionRegistry, user_id}}

  def init(state), do: {:ok, state}

  # API pública

  def join_room(user_id, room_name) do
    GenServer.call(via_tuple(user_id), {:join_room, room_name})
  end

  def leave_room(user_id) do
    GenServer.call(via_tuple(user_id), :leave_room)
  end

  def send_message(user_id, message) do
    GenServer.call(via_tuple(user_id), {:send_message, message})
  end

  def get_room(user_id) do
    GenServer.call(via_tuple(user_id), :get_room)
  end

  # Callbacks

  def handle_call({:join_room, room_name}, _from, state) do
    {:reply, :ok, %{state | room: room_name}}
  end

  def handle_call(:leave_room, _from, state) do
    {:reply, :ok, %{state | room: nil}}
  end

  def handle_call({:send_message, message}, _from, state) do
    if state.room do
      ChatRoom.send_message(state.room, state.user_id, message)
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_in_room}, state}
    end
  end

  def handle_call(:get_room, _from, state) do
    {:reply, state.room, state}
  end
end
