defmodule CommerceCure.Month do
  alias __MODULE__
  @moduledoc """
  assumes months are from 1 to 12; sorry about the other calendars
  """

  @type month :: integer

  @type t :: %__MODULE__{month: month}
  @enforce_keys [:month]
  defstruct [:month]

  @doc """
  underpinned by Integer.parse/1
  iex> Month.new("01")
  {:ok, %Month{month: 1}}
  iex> Month.new(11)
  {:ok, %Month{month: 11}}
  iex> Month.new("9ab")
  {:ok, %Month{month: 9}}
  iex> Month.new("ab11")
  {:error, :not_integer}
  iex> Month.new(13)
  {:error, :invalid_month}
  """
  @spec new(integer | String.t) :: {:ok, t} | {:error, atom}
  def new(month)
  def new(term) when is_binary(term) do
    case Integer.parse(term) do
      {int, _} ->
        new(int)
      _ ->
        {:error, :not_integer}
    end
  end

  def new(term) when is_integer(term) do
    if term >= 1 and term <= 12 do
      {:ok, %__MODULE__{month: term}}
    else
      {:error, :invalid_month}
    end
  end

  @doc """
  iex> Month.to_string(%{month: 5})
  "05"
  """
  @spec to_string(t) :: String.t
  def to_string(%{month: month}) do
    "#{month}" |> String.pad_leading(2, "0")
  end

  ## Helpers

  defimpl String.Chars do
    @doc """
    iex> Month.new(11) |> to_string()
    "11"
    """
    def to_string(%{month: month}) do
      Month.to_string(%{month: month})
    end
  end
end
