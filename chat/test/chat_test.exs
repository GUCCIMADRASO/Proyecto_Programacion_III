defmodule ChatTest do
  use ExUnit.Case

  alias ServidorChat
  alias SalaChat

  setup do
    # Iniciar el servidor de chat antes de cada prueba
    {:ok, _pid} = ServidorChat.start_link([])
    :ok
  end

  test "registro de usuario" do
    assert ServidorChat.registrar_usuario("usuario1", "password") == :ok
    assert ServidorChat.registrar_usuario("usuario1", "password") == {:error, :usuario_existe}
  end

  test "listar usuarios conectados" do
    ServidorChat.registrar_usuario("usuario1", "password")
    assert ServidorChat.listar_usuarios() == ["usuario1"]
  end

  test "crear y unirse a una sala" do
    assert ServidorChat.crear_sala("sala1") == :ok
    assert ServidorChat.unirse_sala("usuario1", "sala1") == {:error, :no_encontrado}

    ServidorChat.registrar_usuario("usuario1", "password")
    assert ServidorChat.unirse_sala("usuario1", "sala1") == :ok
  end

  test "enviar y buscar mensajes en el historial" do
    ServidorChat.registrar_usuario("usuario1", "password")
    ServidorChat.crear_sala("sala1")
    ServidorChat.unirse_sala("usuario1", "sala1")

    assert ServidorChat.enviar_mensaje("usuario1", "Hola mundo") == :ok
    assert SalaChat.buscar_en_historial("sala1", "Hola") == ["%{mensaje: \"Hola mundo\", marca_tiempo: _, usuario: \"usuario1\"}"]
  end
end
