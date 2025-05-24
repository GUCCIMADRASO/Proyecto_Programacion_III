defmodule Cliente do
  @moduledoc """
  Interfaz de línea de comandos para el usuario.
  """

  # Aquí se implementará la CLI y comandos interactivos

  def principal do
    IO.puts("¡Bienvenido al Chat Distribuido!")
    IO.puts("Ingrese su usuario:")
    usuario = IO.gets("") |> String.trim()
    IO.puts("Ingrese su contraseña:")
    contrasena = IO.gets("") |> String.trim()
    Autenticacion.start_link()
    case Autenticacion.autenticar(usuario, contrasena) do
      true ->
        IO.puts("Autenticado.\nEscriba /ayuda para ver comandos.")
        bucle(usuario)
      false ->
        case Autenticacion.registrar(usuario, contrasena) do
          true ->
            IO.puts("Usuario registrado y autenticado.\nEscriba /ayuda para ver comandos.")
            bucle(usuario)
          _ ->
            IO.puts("No se pudo autenticar ni registrar.")
        end
    end
  end

  defp bucle(usuario) do
    entrada = IO.gets("") |> String.trim()
    case String.split(entrada) do
      ["/ayuda"] ->
        IO.puts("Comandos disponibles:")
        IO.puts("/listar - Lista todos los usuarios conectados.")
        IO.puts("/crear <sala> - Crea una nueva sala de chat.")
        IO.puts("/unirse <sala> - Únase a una sala de chat existente.")
        IO.puts("/historial - Muestra el historial de mensajes de la sala actual.")
        IO.puts("/salir - Salir del chat.")
        IO.puts("<mensaje> - Enviar un mensaje a la sala actual.")
        bucle(usuario)
      ["/listar"] ->
        usuarios = ServidorChat.listar_usuarios()
        IO.inspect(usuarios)
        bucle(usuario)
      ["/crear", sala] ->
        case ServidorChat.crear_sala(sala) do
          :ok -> IO.puts("Sala creada.")
          {:error, _} -> IO.puts("No se pudo crear la sala.")
        end
        bucle(usuario)
      ["/unirse", sala] ->
        case ServidorChat.unirse_sala(usuario, sala) do
          :ok -> IO.puts("Unido a la sala #{sala}.")
          {:error, _} -> IO.puts("No se pudo unir a la sala.")
        end
        bucle(usuario)
      ["/historial"] ->
        sala = SesionUsuario.obtener_sala(usuario)
        if sala do
          historial = ServidorChat.obtener_historial(sala)
          IO.inspect(historial)
        else
          IO.puts("No está en ninguna sala.")
        end
        bucle(usuario)
      ["/salir"] ->
        IO.puts("Saliendo...")
        :ok
      _ ->
        sala = SesionUsuario.obtener_sala(usuario)
        if sala do
          ServidorChat.enviar_mensaje(usuario, entrada)
        else
          IO.puts("Debe unirse a una sala para enviar mensajes.")
        end
        bucle(usuario)
    end
  end

  def conectar_servidor(host, port) do
    {:ok, socket} = :gen_tcp.connect(String.to_charlist(host), port, [:binary, active: false])
    {:ok, socket}
  end

  def enviar_comando(socket, comando) do
    :gen_tcp.send(socket, comando <> "\n")
    case :gen_tcp.recv(socket, 0) do
      {:ok, respuesta} -> IO.puts("Respuesta del servidor: #{respuesta}")
      {:error, _} -> IO.puts("Error al recibir respuesta del servidor.")
    end
  end

  def principal(host, port) do
    case conectar_servidor(host, port) do
      {:ok, socket} ->
        IO.puts("Conectado al servidor en #{host}:#{port}")
        bucle(socket)
      {:error, _} ->
        IO.puts("No se pudo conectar al servidor.")
    end
  end

  defp bucle(socket) do
    entrada = IO.gets("") |> String.trim()
    :gen_tcp.send(socket, entrada <> "\n")
    case :gen_tcp.recv(socket, 0) do
      {:ok, respuesta} ->
        IO.puts("Respuesta del servidor: #{respuesta}")
        bucle(socket)
      {:error, :closed} ->
        IO.puts("Conexión cerrada por el servidor.")
    end
  end
end
