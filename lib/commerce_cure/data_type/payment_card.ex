defmodule CommerceCure.PaymentCard do
  alias __MODULE__
  alias CommerceCure.PaymentCardNumber
  alias CommerceCure.{ExpiryDate, Year, Month, Name}

  @type t :: %__MODULE__{
               number:     PaymentCardNumber.number,
               first_name: Name.first_name,
               last_name:  Name.last_name,
               month:      Month.month,
               year:       Year.year,
               brand:      PaymentCardNumber.brand,
               verification_value: String.t
             }

  @enforce_keys [:number]
  defstruct [:first_name, :last_name, :month, :year, :brand, :number, :verification_value]

  @doc """
  iex> PaymentCard.new(4242424242424242)
  {:ok, %PaymentCard{number: "4242424242424242", brand: :visa}}
  iex> PaymentCard.new("4242424242424242")
  {:ok, %PaymentCard{number: "4242424242424242", brand: :visa}}
  iex> PaymentCard.new(%{number: 4242424242424242, expiry_date: "02/17", name: "Commerce Cure", verification_value: "245"})
  {:ok, %PaymentCard{number: "4242424242424242", brand: :visa, year: 2017, month: 2, first_name: "Commerce", last_name: "Cure", verification_value: "245"}}
  iex> PaymentCard.new(%{number: 4242424242424242, expiry_date: "13/17", name: "Commerce Cure", verification_value: "245"})
  {:error, :invalid_month}
  """
  @spec new(integer | String.t | map) :: {:ok, t}
  def new(number) when is_binary(number) or is_integer(number) do
    case PaymentCardNumber.new(number) do
      {:ok, %{brand: brand, number: number}} ->
        {:ok, %__MODULE__{brand: brand, number: number}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def new(%{number: number} = map) do
    with {:ok, %{brand: brand, number: number}} <- PaymentCardNumber.new(number),
         {:ok, %{year: year, month: month}} <- new_expiry(map),
         {:ok, %{first_name: first_name, last_name: last_name}} <- new_name(map),
         {:ok, %{verification_value: verification_value}} <- new_verification_value(map, brand)
    do
      {:ok, %__MODULE__{brand: brand, number: number,
                        year: year, month: month,
                        first_name: first_name, last_name: last_name,
                        verification_value: verification_value}}
    end
  end

  def new(list) when is_list(list) do
    list
    |> Enum.into(%{})
    |> new()
  end

  @doc """
  iex> %PaymentCard{number: "4242424242424242"}[:number]
  "4242424242424242"
  iex> %PaymentCard{number: "4242424242424242", year: 2015, month: 7}[:expiry_date]
  "0715"
  iex> %PaymentCard{number: "4242424242424242", first_name: "Commerce", last_name: "Cure"}[:name]
  "Commerce Cure"
  """
  # TODO: use bang functions and try{}
  @spec fetch(t, atom) :: any
  def fetch(payment_card, key)
  def fetch(%PaymentCard{first_name: first, last_name: last}, :name) do
    {:ok, full_name(%{first_name: first, last_name: last})}
  end
  def fetch(%PaymentCard{year: year, month: month}, :expiry_date) do
    {:ok, expiry_date(%{year: year, month: month})}
  end

  def fetch(%__MODULE__{} = me, key) do
    if value = Map.get(me, key),
      do: {:ok, value},
    else: :error
  end

  ### Shortcuts
  @doc """
  iex> PaymentCard.full_name(%{first_name: "Commerce", last_name: "Cure"})
  "Commerce Cure"
  """
  @spec full_name(t) :: String.t
  def full_name(%{first_name: first, last_name: last}) do
    "#{first} #{last}"
  end

  @doc """
  iex> PaymentCard.expiry_date(%{year: 2017, month: 5})
  "0517"
  """
  @spec expiry_date(t) :: String.t
  def expiry_date(%{year: year, month: month}) do
    ExpiryDate.format(%{year: year, month: month}, "MMYY")
  end

  # year, month > expiry_date
  defp new_expiry(%{year: year, month: month}) do
    with {:ok, %{year: year}}   <- Year.new(year),
         {:ok, %{month: month}} <- Month.new(month)
    do
      {:ok, %{year: year, month: month}}
    end
  end

  defp new_expiry(%{expiry_date: expiry_date}) do
    ExpiryDate.parse(expiry_date, "MM/YY")
  end

  defp new_expiry(_), do: {:ok, %{year: nil, month: nil}}

  # first_name, last_name > name | full_name
  defp new_name(%{first_name: first, last_name: last})
    when is_binary(first) and is_binary(last)
  do
    Name.new(%{first_name: first, last_name: last})
  end
  defp new_name(%{name: name}) when is_binary(name), do: Name.parse(name)
  defp new_name(%{full_name: name}), do: Name.parse(name)
  defp new_name(_), do: {:ok, %{first_name: nil, last_name: nil}}

  #
  defp new_verification_value(%{verification_value: vv}, brand)
    when is_binary(vv)
  do
    if verification_value?(vv, brand) do
      {:ok, %{verification_value: vv}}
    else
      {:error, :invalid_verification_value}
    end
  end
  defp new_verification_value(_, _), do: {:ok, %{verification_value: nil}}

  defp verification_value?(vv, brand) do
    if brand == :american_express do
      String.length(vv) == 4
    else
      String.length(vv) == 3
    end
  end
end
