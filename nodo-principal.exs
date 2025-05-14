defmodule NodoCliente do
  @nombre_servicio_local :servicio_respuesta
  @servicio_local {@nombre_servicio_local, :nodocliente@cliente}
  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:servicio_cadenas, @nodo_remoto}

  def main() do
    Util.mostrar_mensaje("PROCESO PRINCIPAL")
    @nombre_servicio_local
    |> registrar_servicio()
    establecer_conexion(@nodo_remoto)
    |> iniciar_produccion()
  end

  defp registrar_servicio(nombre_servicio_local) do
    Process.register(self(), nombre_servicio_local)
  end

  defp establecer_conexion(nodo_remoto) do
    Node.connect(nodo_remoto)
  end

  defp iniciar_produccion(false) do
    Util.mostrar_error("No se pudo conectar con el nodo servidor")
  end

  defp iniciar_produccion(true) do
    enviar_mensajes()
    recibir_respuestas()
  end

  defp enviar_mensajes() do
    loop_enviar_mensajes()
  end

  defp loop_enviar_mensajes() do
    mensaje = Util.ingresar("Ingrese un mensaje (o escriba 'fin' para terminar):", :texto)

    case mensaje do
      "fin" ->
        send(@servicio_remoto, {@servicio_local, :fin})
        Util.mostrar_mensaje("Chat finalizado.")

      _ ->
        send(@servicio_remoto, {@servicio_local, {:texto, mensaje}})
        loop_enviar_mensajes()
    end
  end

  defp recibir_respuestas() do
    receive do
      :fin ->
        :ok

      respuesta ->
        Util.mostrar_mensaje("\t->\"#{respuesta}\"")
        recibir_respuestas()
    end
  end
end

NodoCliente.main()
