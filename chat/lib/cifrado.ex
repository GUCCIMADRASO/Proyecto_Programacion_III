defmodule Cifrado do
  @moduledoc """
  Cifrado simbólico para mensajes en tránsito.
  """

  def cifrar(mensaje), do: Base.encode64(mensaje)
  def descifrar(mensaje), do: Base.decode64!(mensaje)
end
