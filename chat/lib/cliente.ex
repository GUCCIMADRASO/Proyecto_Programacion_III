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
    Autenticacion.iniciar_enlace()
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
end
