defmodule CommerceCure.Year do
  @moduledoc """
  Assumes years are from 1000 - 9999
  """
  alias __MODULE__

  @type year :: integer

  @type t :: %Year{year: year}
  @enforce_keys [:year]
  defstruct [:year]

  @doc """
  iex> Year.new(17)
  {:ok, %Year{year: 2017}}
  iex> Year.new("114")
  {:ok, %Year{year: 2114}}
  iex> Year.new("12whs")
  {:ok, %Year{year: 2012}}
  iex> Year.new("whs12")
  {:error, :not_integer}

  underpinned with Integer.parse/1 for string parsing
  years larger than 9999 or smaller than 0 will raise
  """
  @spec new(String.t | integer) :: {:ok, t} | {:error, atom}
  def new(year)
  def new(term) when is_integer(term) do
    {:ok, %__MODULE__{year: prepend_millenium(term)}}
  end
  def new(term) when is_binary(term) do
    case Integer.parse(term) do
      {int, _} ->
        new(int)
      _ ->
        {:error, :not_integer}
    end
  end


  @doc """
  iex> Year.to_two_digits(%{year: 4242})
  "42"
  """
  @spec to_two_digits(t) :: String.t
  def to_two_digits(%{year: year}) do
    year
    |> Integer.digits()
    |> Enum.slice(-2..-1)
    |> Enum.join()
  end

  @doc """
  iex> Year.to_string(%{year: 2017})
  "2017"
  """
  @spec to_string(t) :: String.t
  def to_string(%{year: year}), do: "#{year}"

  defp prepend_millenium(year, prepend_year \\ Date.utc_today())
  defp prepend_millenium(year, %{year: prepend_year}) when year > 0 and year <= 999 do
    year = Integer.digits(year)

    prepend_year
    |> Integer.digits()
    |> Enum.slice(0..-length(year)-1)
    |> Kernel.++(year)
    |> Integer.undigits()
  end
  defp prepend_millenium(year, _) when year > 999 and year <= 9999, do: year
  defp prepend_millenium(year, _) when year > 9999 do
    raise ArgumentError, "#{inspect year} cannot be larger than 9999"
  end
  defp prepend_millenium(year, _) when year < 0 do
    raise ArgumentError, "#{inspect year} cannot be negative"
  end

  ## Helpers

  defimpl String.Chars do
    @doc """
    iex> Year.new(1562) |> to_string()
    "1562"
    """
    def to_string(%{year: year}) do
      Year.to_string(%{year: year})
    end
  end
end
