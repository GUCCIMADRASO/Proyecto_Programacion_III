defmodule Auth do
  @moduledoc """
  Autenticación básica de usuarios.
  """

  # API pública

  def register(user_id, password) do
    :ets.insert_new(:auth_table, {user_id, password})
  end

  def authenticate(user_id, password) do
    case :ets.lookup(:auth_table, user_id) do
      [{^user_id, ^password}] -> true
      _ -> false
    end
  end

  # Inicialización de ETS

  def start_link do
    :ets.new(:auth_table, [:named_table, :public, :set])
    {:ok, self()}
  end
end
