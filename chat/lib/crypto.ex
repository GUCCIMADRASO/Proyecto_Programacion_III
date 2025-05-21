defmodule Crypto do
  @moduledoc """
  Cifrado simbólico para mensajes en tránsito.
  """

  def encrypt(msg), do: Base.encode64(msg)
  def decrypt(msg), do: Base.decode64!(msg)
end
