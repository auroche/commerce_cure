defmodule CommerceCure.AvsCode do
  # Implements the Address Verification System
  # https://www.wellsfargo.com/downloads/pdf/biz/merchant/visa_avs.pdf
  # http://en.wikipedia.org/wiki/Address_Verification_System
  # http://apps.cybersource.com/library/documentation/dev_guides/CC_Svcs_IG/html/app_avs_cvn_codes.htm#app_AVS_CVN_codes_7891_48375
  # http://imgserver.skipjack.com/imgServer/5293710/AVS%20and%20CVV2.pdf
  # http://www.emsecommerce.net/avs_cvv2_response_codes.htm

  @messages %{
    "A" => "Street address matches, but 5-digit and 9-digit postal code do not match.",
    "B" => "Street address matches, but postal code not verified.",
    "C" => "Street address and postal code do not match.",
    "D" => "Street address and postal code match.",
    "E" => "AVS data is invalid or AVS is not allowed for this card type.",
    "F" => "Card member\'s name does not match, but billing postal code matches.",
    "G" => "Non-U.S. issuing bank does not support AVS.",
    "H" => "Card member\'s name does not match. Street address and postal code match.",
    "I" => "Address not verified.",
    "J" => "Card member\'s name, billing address, and postal code match. Shipping information verified and chargeback protection guaranteed through the Fraud Protection Program.",
    "K" => "Card member\'s name matches but billing address and billing postal code do not match.",
    "L" => "Card member\'s name and billing postal code match, but billing address does not match.",
    "M" => "Street address and postal code match.",
    "N" => "Street address and postal code do not match.",
    "O" => "Card member\'s name and billing address match, but billing postal code does not match.",
    "P" => "Postal code matches, but street address not verified.",
    "Q" => "Card member\'s name, billing address, and postal code match. Shipping information verified but chargeback protection not guaranteed.",
    "R" => "System unavailable.",
    "S" => "U.S.-issuing bank does not support AVS.",
    "T" => "Card member\'s name does not match, but street address matches.",
    "U" => "Address information unavailable.",
    "V" => "Card member\'s name, billing address, and billing postal code match.",
    "W" => "Street address does not match, but 9-digit postal code matches.",
    "X" => "Street address and 9-digit postal code match.",
    "Y" => "Street address and 5-digit postal code match.",
    "Z" => "Street address does not match, but 5-digit postal code matches."
  }

  # Map vendor"s AVS result code to a postal match code
  @postal_match_code %{
    "Y" => ~w( D H F H J L M P Q V W X Y Z ),
    "N" => ~w( A C K N O ),
    "X" => ~w( G S ),
    nil => ~w( B E I R T U )
  }

  # Map vendor"s AVS result code to a street match code
  @street_match_code %{
    "Y" => ~w( A B D H J M O Q T V X Y ),
    "N" => ~w( C K L N W Z ),
    "X" => ~w( G S ),
    nil => ~w( E F I P R U )
  }

  @enforce_keys [:code, :message]
  defstruct     [:code, :message, :street_match, :postal_match]

  def new(code, street_match \\ nil, postal_match \\ nil)
  def new(code, street_match, postal_match)
    when is_binary(street_match) and is_binary(postal_match)
  do
    message = message(code)
    street_match = if street_match, do: String.upcase(street_match), else: street_match(code)
    postal_match = if postal_match, do: String.upcase(postal_match), else: postal_match(code)
    if message && street_match && postal_match do
      {:ok, %__MODULE__{code: code, message: message,
                        street_match: street_match,
                        postal_match: postal_match}}
    else
      {:error, :invalid_code}
    end
  end

  def message(code) when is_binary(code), do: Map.get(@messages, code)
  def message(code) when is_atom(code), do: code |> Atom.to_string() |> String.upcase |> message

  def postal_match(code) when is_binary(code), do: Map.get(@postal_match_code, code)
  def postal_match(code) when is_atom(code), do: code |> Atom.to_string() |> String.upcase |> postal_match

  def street_match(code) when is_binary(code), do: Map.get(@street_match_code, code)
  def street_match(code) when is_atom(code), do: code |> Atom.to_string() |> String.upcase |> street_match
end
