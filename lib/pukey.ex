defmodule Pukey do
  @moduledoc """
  Weak xml transformations
  """

  @type xml :: String.t

  @spec encode(map | Keyword.t, Keyword.t) :: xml
  def encode(any, opts \\ [])
  def encode(any, _opts) do
    {:ok, Pukey.Encoder.encode(any)}
  end

  def encode!(any, opts \\ [])
  def encode!(any, opts) do
    case encode(any, opts) do
      {:ok, encoded} ->
        encoded
      {:error, reason} ->
        raise ArgumentError, "#{reason}"
    end
  end

  @spec decode(xml, Keyword.t) :: Keyword.t
  def decode(xml, opts \\ [])
  def decode(string, _opts) when is_binary(string) do
    {:ok, Pukey.Decoder.decode(string)}
  end

  def decode!(any, opts \\ [])
  def decode!(xml, opts) do
    case decode(xml, opts) do
      {:ok, decoded} ->
        decoded
      {:error, reason} ->
        raise ArgumentError, "#{reason}"
    end
  end
end
