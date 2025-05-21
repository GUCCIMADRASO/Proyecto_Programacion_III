defmodule ChatServer do
  use GenServer

  # Estado: %{users: %{user_id => pid}, rooms: %{room_name => pid}}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{
      users: %{},
      rooms: %{}
    }, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  # API pública

  def register_user(user_id, password) do
    GenServer.call(__MODULE__, {:register_user, user_id, password})
  end

  def list_users do
    GenServer.call(__MODULE__, :list_users)
  end

  def create_room(room_name) do
    GenServer.call(__MODULE__, {:create_room, room_name})
  end

  def join_room(user_id, room_name) do
    GenServer.call(__MODULE__, {:join_room, user_id, room_name})
  end

  def leave_room(user_id) do
    GenServer.call(__MODULE__, {:leave_room, user_id})
  end

  def send_message(user_id, message) do
    GenServer.call(__MODULE__, {:send_message, user_id, message})
  end

  def get_history(room_name) do
    GenServer.call(__MODULE__, {:get_history, room_name})
  end

  # Callbacks

  def handle_call({:register_user, user_id, password}, _from, state) do
    case Map.has_key?(state.users, user_id) do
      true -> {:reply, {:error, :user_exists}, state}
      false ->
        {:ok, _pid} = UserSession.start_link(user_id)
        Auth.register(user_id, password)
        users = Map.put(state.users, user_id, self())
        {:reply, :ok, %{state | users: users}}
    end
  end

  def handle_call(:list_users, _from, state) do
    {:reply, Map.keys(state.users), state}
  end

  def handle_call({:create_room, room_name}, _from, state) do
    case Map.has_key?(state.rooms, room_name) do
      true -> {:reply, {:error, :room_exists}, state}
      false ->
        {:ok, _pid} = ChatRoom.start_link(room_name)
        rooms = Map.put(state.rooms, room_name, self())
        {:reply, :ok, %{state | rooms: rooms}}
    end
  end

  def handle_call({:join_room, user_id, room_name}, _from, state) do
    if Map.has_key?(state.rooms, room_name) and Map.has_key?(state.users, user_id) do
      ChatRoom.add_user(room_name, user_id)
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:leave_room, user_id}, _from, state) do
    Enum.each(state.rooms, fn {room, _pid} ->
      ChatRoom.remove_user(room, user_id)
    end)
    {:reply, :ok, state}
  end

  def handle_call({:send_message, user_id, message}, _from, state) do
    # Buscar la sala del usuario
    room = Enum.find_value(state.rooms, fn {room, _pid} ->
      if ChatRoom.user_in_room?(room, user_id), do: room, else: nil
    end)
    if room do
      ChatRoom.send_message(room, user_id, message)
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_in_room}, state}
    end
  end

  def handle_call({:get_history, room_name}, _from, state) do
    if Map.has_key?(state.rooms, room_name) do
      history = ChatRoom.get_history(room_name)
      {:reply, history, state}
    else
      {:reply, {:error, :not_found}, state}
    end
  end
end
