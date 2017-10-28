defmodule CommerceCure.BillingAddress do
  alias CommerceCure.{Name, Phone, Address}

  @moduledoc """
  Billing Address have the following:
  :name    - The full name of the customer
  :comapny - The company name of the customer
  :phone   - The phone number of the customer
  :suite   - The suite or apartment number of the address
  :street_number - The street number of the address
  :street  - The street of the address
  :city    - The city of the address
  :province - The province of the address = The 2 digit code for US and Canadian addresses. The full name of the state or province for foreign addresses.
  :country - The country of the address = The [ISO 3166-1-alpha-3 code](http://www.iso.org/iso/country_codes/iso_3166_code_lists/english_country_names_and_code_elements.htm) for the customer.
  :postal_code - The postal code of the address
  """

  @type company :: String.t
  @type t :: %__MODULE__{
               name:    Name.name,
               company: company,
               phone:   Phone.phone_number,
               suite:   Address.suite,
               street_number: Address.street_number,
               street:  Address.street,
               city: Address.city,
               province: Address.province,
               country: Address.country,
               postal_code: Address.postal_code
             }

  defstruct [:name, :company, :phone, :suite, :street_number, :street, :city, :province, :country, :postal_code]
  @doc """
  "6301 Silver Dart Dr, Mississauga, ON L5P 1B2"
  iex> BillingAddress.new(%{name: "Air Canada", phone: "(416) 247-7678", company: "Toronto Pearson International Airport", street: "6301 Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2"})
  {:ok, %BillingAddress{street_number: "6301", street: "Silver Dart Dr", city: "Mississauga", province: "ON", postal_code: "L5P 1B2", phone: "(416) 247-7678", company: "Toronto Pearson International Airport", name: "Air Canada"}}
  """
  @spec new(map) :: t
  def new(map) do
    with {:ok, %{suite: suite, street_number: street_number, street: street,
               city: city, province: province, country: country,
               postal_code: postal_code}} <- new_address(map),
         {:ok, %{name: name}} <- new_name(map),
         {:ok, %{company: company}} <- new_company(map),
         {:ok, %{number: phone_number}} <- new_phone(map)
    do
      {:ok, %__MODULE__{name: name, company: company, phone: phone_number, suite: suite,
                        street_number: street_number, street: street, city: city,
                        province: province, country: country, postal_code: postal_code}}
    end
  end

  @spec fetch(t, atom) :: String.t
  def fetch(address, key)
  def fetch(%__MODULE__{} = me, key) do
    if value = Map.get(me, key),
      do: {:ok, value},
    else: :error
  end

  defp new_address(%{address: address}) when is_binary(address) do
    Address.parse(address)
  end
  defp new_address(address) when is_map(address) do
    Address.new(address)
  end
  defp new_address(_) do
    {:ok, %Address{suite: nil, street_number: nil, street: nil, city: nil,
            province: nil, country: nil, postal_code: nil}}
  end

  defp new_name(%{name: name}) do
    {:ok, %{name: name |> Name.new!() |> to_string()}}
  end
  defp new_name(_), do: {:ok, %{name: nil}}

  defp new_company(%{company: company}) when is_binary(company) do
    {:ok, %{company: company}}
  end
  defp new_company(_), do: {:ok, %{company: nil}}

  defp new_phone(%{phone: number}) do
    Phone.new(number)
  end
  defp new_phone(_), do: {:ok, %{number: nil}}
end
