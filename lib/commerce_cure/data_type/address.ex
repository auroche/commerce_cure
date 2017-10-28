defmodule CommerceCure.Address do
  @type suite :: String.t
  @type street_number :: String.t
  @type street :: String.t
  @type city :: String.t
  @type province :: String.t
  @type country :: String.t
  @type postal_code :: String.t
  @type t :: %__MODULE__{
               suite: String.t | nil,
               street_number: String.t,
               street: String.t,
               city: String.t,
               province: String.t | nil,
               country: String.t,
               postal_code: String.t
             }

  @enforce_keys []
  defstruct [:suite, :street_number, :street, :city, :province, :country, :postal_code]

  @doc """
  "6301 Silver Dart Dr, Mississauga, ON L5P 1B2"
  iex> Address.new(%{street: "6301 Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2"})
  {:ok, %Address{street_number: "6301", street: "Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2"}}
  """
  @spec new(map | binary) :: {:ok, t} | {:error, atom}
  def new(term)
  def new(string) when is_binary(string) do
    parse(string)
  end

  def new(map) when is_map(map) do
    with {:ok, country: country} <- new_country(map),
         {:ok, province: province} <- new_province(map),
         {:ok, city: city} <- new_city(map),
         {:ok, street_number: number, street: street} <- new_street(map),
         {:ok, suite: suite} <- new_suite(map),
         {:ok, postal_code: postal_code} <- new_postal_code(map)
    do
      {:ok, %__MODULE__{country: country, province: province, city: city, street: street,
                        street_number: number, suite: suite, postal_code: postal_code}}
    end
  end

  @doc """
  iex> Address.parse!("6301 Silver Dart Dr, Mississauga L5P 1B2")[:city]
  "Mississauga"
  """
  @spec fetch(t, atom) :: String.t
  def fetch(address, key)
  def fetch(%__MODULE__{} = me, key) do
    if value = Map.get(me, key),
      do: {:ok, value},
    else: :error
  end

  @spec parse!(String.t) :: t | nil
  def parse!(string)
  def parse!(string) do
    case parse(string) do
      {:ok, parsed} -> parsed
      {:error, reason} -> raise ArgumentError, "#{inspect string} has error of #{inspect reason}"
    end
  end

  @doc """
  iex> Address.parse("6301 Silver Dart Dr, Mississauga L5P 1B2")
  {:ok, %Address{street_number: "6301", street: "Silver Dart Dr", city: "Mississauga", postal_code: "L5P 1B2"}}
  iex> Address.parse("6301 Silver Dart Dr, Mississauga, ON L5P 1B2")
  {:ok, %Address{street_number: "6301", street: "Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2"}}
  iex> Address.parse("6301 Silver Dart Dr, Mississauga, ON, Canada L5P 1B2")
  {:ok, %Address{street_number: "6301", street: "Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2", country: "Canada"}}
  """
  # BUG: will not work for every occasion
  # TODO: needs improvment
  @spec parse(binary) :: {:ok, t} | {:error, atom}
  def parse(string) when is_binary(string) do
    string
    |> String.split(~r/[,\n]/)
    |> parse(0, [])
  end

  defp parse(string_pieces, n, result)
  defp parse([], _, result), do: {:ok, struct(%__MODULE__{}, result)}
  defp parse({:error, reason}, _, _result), do: {:error, reason}

  defp parse([ last | [] ], n, result) do
    {postal_code, last_piece} = capture_postal_code(last)
    result = if postal_code,
      do: [postal_code: postal_code] ++ result,
    else: result

    do_parse(last_piece, [], n, result)
  end

  defp parse([ _ | _ ], 4, result) do
    parse({:error, :too_many_addresses}, 4, result)
  end

  defp parse([one | pieces], n, result) do
    do_parse(one, pieces, n, result)
  end

  defp do_parse(one, pieces, n, result) do
    parsed = case n do
      0 -> parse_street(one)
      1 -> parse_city(one)
      2 -> parse_province(one)
      3 -> parse_country(one)
    end

    case parsed do
      {:ok, new_results} ->
        parse(pieces, n + 1, new_results ++ result)
      {:error, reason} ->
        parse({:error, reason}, n, result)
    end
  end

  defp parse_street(string) when is_binary(string) do
    case String.split(string) do
      [_ | []] ->
        {:error, :invalid_street}
      [number | street] ->
        {:ok, street_number: number, street: Enum.join(street, " ")}
      _ ->
        {:error, :invalid_street}
    end
  end

  defp parse_city(string) when is_binary(string) do
    {:ok, city: String.trim(string)}
  end

  defp parse_province(string) when is_binary(string) do
    {:ok, province: String.trim(string)}
  end

  # TODO: check country
  defp parse_country(string) when is_binary(string) do
    {:ok, country: String.trim(string)}
  end

  defp new_postal_code(%{postal_code: postal_code}) do
    if postal_code?(postal_code) do
      {:ok, postal_code: postal_code}
    else
      {:error, :invalid_postal_code}
    end
  end
  defp new_postal_code(_), do: {:ok, postal_code: nil}

  defp new_suite(%{suite: suite}) do
    if suite?(suite) do
      {:ok, suite: suite}
    else
      {:error, :invalid_suite}
    end
  end
  defp new_suite(_), do: {:ok, suite: nil}

  defp new_street(%{street_number: number, street: street})
    when is_binary(number) and is_binary(street)
  do
    {:ok, street_number: number, street: street}
  end

  defp new_street(%{street: street}) when is_binary(street) do
    [ number | street ] = String.split(street)
    street = Enum.join(street, " ")
    if street_number?(number) do
      if street?(street) do
        {:ok, street_number: number, street: street}
      else
        {:error, :invalid_street}
      end
    else
      {:error, :invalid_street_number}
    end
  end

  defp new_city(%{city: city}) when is_binary(city) do
    {:ok, city: city}
  end

  defp new_province(%{province: province, country: _country}) when is_binary(province) do
    {:ok, province: province}
  end
  defp new_province(%{province: province}) when is_binary(province) do
    {:ok, province: province}
  end
  defp new_province(_), do: {:ok, province: nil}

  # TODO: check country
  defp new_country(%{country: country}) when is_binary(country) do
    {:ok, country: country}
  end
  defp new_country(_), do: {:ok, country: nil}

  defp suite?(string) do
    String.match?(string, ~r/\d/)
  end

  defp street_number?(string) do
    String.match?(string, ~r/\d/)
  end

  # BUG: this isn't really a real validation
  defp street?(string) do
    string
    |> String.split()
    |> length()
    |> Kernel.>=(2)
  end

  # assumes "Canada H0H 0H0" or "NT H0H 0H0"
  defp capture_postal_code(string) do
    string = String.trim(string)
    case Regex.run(~r/(\w\d\w\d\w\d|\w\d\w \d\w\d)?$/, string, capture: :first) do
      nil ->
        {nil, string}
      [postal_code] ->
        len = String.length(postal_code) + 1
        {postal_code, String.slice(string, 0..-len)}
    end
  end

  defp postal_code?(string) do
    String.match?(string, ~r/^(\w\d\w\d\w\d|\w\d\w \d\w\d)$/)
  end

  # defp postal_code?(string) do
  #   String.match?(string, ~r/^\d{5}$/)
  # end
end
