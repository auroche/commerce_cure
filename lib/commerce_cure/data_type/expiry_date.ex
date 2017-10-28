defmodule CommerceCure.ExpiryDate do
  alias __MODULE__
  alias CommerceCure.Year
  alias CommerceCure.Month

  @type t :: %__MODULE__{year: Year.year, month: Month.month}
  @enforce_keys [:year, :month]
  defstruct [:year, :month]

  @doc """
  iex> ExpiryDate.new(5, 1234)
  {:ok, %ExpiryDate{year: 1234, month: 5}}
  iex> ExpiryDate.new("05", 1234)
  {:ok, %ExpiryDate{year: 1234, month: 5}}
  iex> ExpiryDate.new(5, "1234")
  {:ok, %ExpiryDate{year: 1234, month: 5}}
  iex> ExpiryDate.new(15, 1234)
  {:error, :invalid_month}
  """
  @spec new(integer | String.t, integer | String.t) :: {:ok, t} | {:error, atom} | nil
  def new(month, year) do
    with {:ok, %{month: month}} <- Month.new(month),
         {:ok, %{year: year}}  <- Year.new(year)
    do
      {:ok, %ExpiryDate{year: year, month: month}}
    else
      {:error, reason} ->
        {:error, reason}
      any ->
        raise ArgumentError, "#{inspect any} is an unknown error"
    end
  end

  @doc """
  iex> ExpiryDate.parse("11/24")
  {:ok, %ExpiryDate{year: 2024, month: 11}}
  iex> ExpiryDate.parse("12/2014", "MM/yyyy")
  {:ok, %ExpiryDate{year: 2014, month: 12}}
  iex> ExpiryDate.parse("14/20a4", "MM/yyyy")
  {:error, :invalid_string}
  iex> ExpiryDate.parse("14/2014", "MM/yyyy")
  {:error, :invalid_month}
  iex> ExpiryDate.parse("14/2014")
  {:error, :string_does_not_match_format}
  """
  @spec parse(String.t, String.t) :: {:ok, t} | {:error, atom} | nil
  def parse(string, format \\ "MM/YY") when is_binary(string) do
    with :ok <- validate_string(string, format),
         {:ok, month} <- parse_month(string, format),
         {:ok, year}  <- parse_year(string, format)
    do
      new(month, year)
    else
      {:error, reason} ->
        {:error, reason}
      any ->
        raise ArgumentError, "#{inspect any} is an unknown error"
    end
  end

  @spec parse!(String.t, String.t) :: t | nil
  def parse!(string, format \\ "MM/YY") do
    case parse(string, format) do
      {:ok, expiry_date} ->
        expiry_date
      {:error, reason} ->
        raise ArgumentError, "#{inspect reason}"
    end
  end

  @doc """
  iex> ExpiryDate.format(%{year: 1234, month: 5})
  "05/34"
  iex> ExpiryDate.format(%{year: 2017, month: 5}, "yyyy/MM")
  "2017/05"
  iex> ExpiryDate.format(%{year: 2017, month: 12}, "yyyy-MM")
  "2017-12"
  """
  # BUG: cannot create ex. y2017-M12
  @spec format(t, String.t) :: String.t
  def format(%{year: year, month: month}, format \\ "MM/YY") do
    format
    |> format_month(month)
    |> format_year2(year)
    |> format_year4(year)
  end

  defp validate_string(string, format) do
    if String.length(string) == String.length(format) do
      :ok
    else
      {:error, :string_does_not_match_format}
    end
  end

  defp parse_month(string, format) do
    parse_from_format(string, format, ~r/MM/)
  end

  defp parse_year(string, format) do
    parse_from_format(string, format, ~r/YY|yyyy/)
  end

  defp parse_from_format(string, format, match) do
    case Regex.run(match, format, return: :index) do
      [{at, len} | []] ->
        matched = String.slice(string, at, len)
        if String.match?(matched, ~r/^\d{#{len}}$/) do
          {:ok, matched}
        else
          {:error, :invalid_string}
        end
      [_|_] ->
        raise ArgumentError, "#{inspect match} should not match more than once within #{inspect format}"
      nil ->
        raise ArgumentError, "#{inspect match} must match within #{inspect format}"
    end
  end

  defp format_month(string, month) do
    String.replace(string, ~r/MM/, Month.to_string(%{month: month}))
  end

  defp format_year2(string, year) do
    String.replace(string, ~r/YY/, Year.to_two_digits(%{year: year}))
  end

  defp format_year4(string, year) do
    String.replace(string, ~r/yyyy/, Year.to_string(%{year: year}))
  end

  ## Helpers

  defimpl String.Chars do
    def to_string(%{year: year, month: month}) do
      ExpiryDate.format(%{year: year, month: month}, "MM/YY")
    end
  end
end
