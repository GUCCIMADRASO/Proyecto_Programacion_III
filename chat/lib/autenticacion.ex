defmodule Autenticacion do
  @moduledoc """
  Autenticación básica de usuarios.
  """

  # API pública

  def registrar(usuario_id, contrasena) do
    :ets.insert_new(:tabla_autenticacion, {usuario_id, contrasena})
  end

  def autenticar(usuario_id, contrasena) do
    case :ets.lookup(:tabla_autenticacion, usuario_id) do
      [{^usuario_id, ^contrasena}] -> true
      _ -> false
    end
  end

  # Inicialización de ETS

  def start_link do
    unless :ets.whereis(:tabla_autenticacion) != :undefined do
      :ets.new(:tabla_autenticacion, [:named_table, :public, :set])
    end
    {:ok, self()}
  end
end
