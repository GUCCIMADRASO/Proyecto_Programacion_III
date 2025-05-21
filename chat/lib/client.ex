defmodule Client do
  @moduledoc """
  Interfaz de línea de comandos para el usuario.
  """

  # Aquí se implementará la CLI y comandos interactivos

  def main do
    IO.puts("Bienvenido al Chat Distribuido!")
    IO.puts("Ingrese su usuario:")
    user = IO.gets("") |> String.trim()
    IO.puts("Ingrese su contraseña:")
    pass = IO.gets("") |> String.trim()
    Auth.start_link()
    case Auth.authenticate(user, pass) do
      true ->
        IO.puts("Autenticado.\nEscriba /help para ver comandos.")
        loop(user)
      false ->
        case Auth.register(user, pass) do
          true ->
            IO.puts("Usuario registrado y autenticado.\nEscriba /help para ver comandos.")
            loop(user)
          _ ->
            IO.puts("No se pudo autenticar ni registrar.")
        end
    end
  end

  defp loop(user) do
    input = IO.gets("") |> String.trim()
    case String.split(input) do
      ["/list"] ->
        users = ChatServer.list_users()
        IO.inspect(users)
        loop(user)
      ["/create", room] ->
        case ChatServer.create_room(room) do
          :ok -> IO.puts("Sala creada.")
          {:error, _} -> IO.puts("No se pudo crear la sala.")
        end
        loop(user)
      ["/join", room] ->
        case ChatServer.join_room(user, room) do
          :ok -> IO.puts("Unido a la sala #{room}.")
          {:error, _} -> IO.puts("No se pudo unir a la sala.")
        end
        loop(user)
      ["/history"] ->
        room = UserSession.get_room(user)
        if room do
          history = ChatServer.get_history(room)
          IO.inspect(history)
        else
          IO.puts("No está en ninguna sala.")
        end
        loop(user)
      ["/exit"] ->
        IO.puts("Saliendo...")
        :ok
      _ ->
        room = UserSession.get_room(user)
        if room do
          ChatServer.send_message(user, input)
        else
          IO.puts("Debe unirse a una sala para enviar mensajes.")
        end
        loop(user)
    end
  end
end
