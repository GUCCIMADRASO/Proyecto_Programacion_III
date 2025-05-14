defmodule Util do
  def mostrar_mensaje(mensaje) do
    IO.puts("#{mensaje}")
  end

  def mostrar_error(mensaje) do
    IO.puts("#{mensaje}")
  end

  def ingresar(mensaje,:texto) do
    mensaje
    |>IO.gets()
    |>String.trim()
  end

  def ingresar(mensaje,:entero) do
    mensaje
    |>Util.ingresar(:texto)
    |>String.to_integer()
  rescue
    ArgumentError->
      "error, se espera que ingrese un numero entero\n"
      |> mostrar_mensaje()
      mensaje
      |>ingresar(:entero)
  end

  def ingresar(mensaje,:real) do
    mensaje
    |>Util.ingresar(:texto)
    |>String.to_float()
  rescue
    ArgumentError->
      "error, se espera que ingrese un numero real\n"
      |> mostrar_mensaje()
      mensaje
      |>ingresar(:real)
  end

  def ingresar(mensaje, :boolean) do
    valor =
      mensaje
      |>ingresar(:texto)
      |>String.downcase()

    Enum.member?(["si","sí","s"],valor)
  end
end
