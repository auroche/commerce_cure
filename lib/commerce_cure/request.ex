defmodule CommerceCure.Request do
  alias CommerceCure.{PaymentCard, Address, BillingAddress, Transaction, Authorization}

  def put(request, data, opts \\ [])

  def put(request, %{amount: _amount, currency: _currency} = money, _opts) do
    put_money(request, money)
  end

  def put(request, %PaymentCard{} = payment_card, _opts) do
    put_payment_card(request, payment_card)
  end

  def put(request, %Address{} = address, opts) do
    put_address(request, address, Keyword.get(opts, :prefix))
  end

  def put_money(request, %{currency: currency} = money) do
    request
    |> Map.put(:amount, Money.to_string(money, symbol: false, separator: ""))
    |> Map.put(:currency, "#{currency}")
  end

  def put_payment_card(request, payment_card) do
    request
    |> Map.put(:card_number, payment_card[:number])
    |> Map.put(:exp_date,    payment_card[:expiry_date])
    |> Map.put(:cvv,         payment_card[:verification_value])
    |> Map.put(:first_name,  payment_card[:first_name])
    |> Map.put(:last_name,   payment_card[:last_name])
  end

  def put_invoice(request, invoice) do
    request
    |> Map.put(:invoice, invoice)
  end

  def put_description(request, description) do
    request
    |> Map.put(:description, description)
  end

  def put_address(request, address, prefix \\ nil) do
    p = if prefix, do: "#{prefix}_", else: ""

    request
    |> Map.put(:"#{p}address_suite",         address[:suite])
    |> Map.put(:"#{p}address_street_number", address[:street_number])
    |> Map.put(:"#{p}address_street",        address[:street])
    |> Map.put(:"#{p}address_city",          address[:city])
    |> Map.put(:"#{p}address_province",      address[:province])
    |> Map.put(:"#{p}address_country",       address[:country])
    |> Map.put(:"#{p}address_postal_code",   address[:postal_code])
    |> puke(:"#{p}address_name",    address[:name])
    |> puke(:"#{p}address_company", address[:company])
    |> puke(:"#{p}address_phone",   address[:phone])
  end

  def put_ip(request, ip) do
    request
    |> Map.put(:ip, ip)
  end

  defp puke(put, put_key, value) do
    if value do
      Map.put(put, put_key, value)
    else
      put
    end
  end

  @callback put_money(map, Money.t) :: map
  @callback put_payment_card(map, PaymentCard.t) :: map
  @callback put_authorization(map, Authorization.t) :: map
  @callback put_transaction(map, Transaction.t) :: map

  @callback put_address(map, Address.t | BillingAddress.t, prefix :: String.t) :: map
  @callback put_invoice(map, String.t) :: map
  @callback put_token(map, Token.t) :: map
  @callback put_verification_value(map, PaymentCard.t) :: map

  @optional_callbacks put_invoice: 2, put_approval_code: 2
  #
  # def add_invoice(form,options)
  #   form[:invoice_number] = truncate((options[:order_id] || options[:invoice]), 10)
  #   form[:description] = truncate(options[:description], 255)
  # end
  #
  #     def add_approval_code(form, authorization)
  #       form[:approval_code] = authorization.split(';').first
  #     end
  #
  #     def add_txn_id(form, authorization)
  #       form[:txn_id] = authorization.split(';').last
  #     end
  #
  #     def authorization_from(response)
  #       [response['approval_code'], response['txn_id']].join(';')
  #     end
  #
  #     def add_creditcard(form, creditcard)
  #       form[:card_number] = creditcard.number
  #       form[:exp_date] = expdate(creditcard)
  #
  #       if creditcard.verification_value?
  #         add_verification_value(form, creditcard)
  #       end
  #
  #       form[:first_name] = truncate(creditcard.first_name, 20)
  #       form[:last_name] = truncate(creditcard.last_name, 30)
  #     end
  #
  #     def add_token(form, token)
  #       form[:token] = token
  #     end
  #
  #     def add_verification_value(form, creditcard)
  #       form[:cvv2cvc2] = creditcard.verification_value
  #       form[:cvv2cvc2_indicator] = '1'
  #     end
  #
  #     def add_customer_data(form, options)
  #       form[:email] = truncate(options[:email], 100) unless empty?(options[:email])
  #       form[:customer_code] = truncate(options[:customer], 10) unless empty?(options[:customer])
  #       form[:customer_number] = options[:customer_number] unless empty?(options[:customer_number])
  #       if options[:custom_fields]
  #         options[:custom_fields].each do |key, value|
  #           form[key.to_s] = value
  #         end
  #       end
  #     end
  #
  #     def add_salestax(form, options)
  #       form[:salestax] = options[:tax] if options[:tax].present?
  #     end
  #
  #     def add_address(form, options)
  #       billing_address = options[:billing_address] || options[:address]
  #
  #       if billing_address
  #         form[:avs_address]    = truncate(billing_address[:address1], 30)
  #         form[:address2]       = truncate(billing_address[:address2], 30)
  #         form[:avs_zip]        = truncate(billing_address[:zip].to_s.gsub(/[^a-zA-Z0-9]/, ''), 9)
  #         form[:city]           = truncate(billing_address[:city], 30)
  #         form[:state]          = truncate(billing_address[:state], 10)
  #         form[:company]        = truncate(billing_address[:company], 50)
  #         form[:phone]          = truncate(billing_address[:phone], 20)
  #         form[:country]        = truncate(billing_address[:country], 50)
  #       end
  #
  #       if shipping_address = options[:shipping_address]
  #         first_name, last_name = split_names(shipping_address[:name])
  #         form[:ship_to_first_name]     = truncate(first_name, 20)
  #         form[:ship_to_last_name]      = truncate(last_name, 30)
  #         form[:ship_to_address1]       = truncate(shipping_address[:address1], 30)
  #         form[:ship_to_address2]       = truncate(shipping_address[:address2], 30)
  #         form[:ship_to_city]           = truncate(shipping_address[:city], 30)
  #         form[:ship_to_state]          = truncate(shipping_address[:state], 10)
  #         form[:ship_to_company]        = truncate(shipping_address[:company], 50)
  #         form[:ship_to_country]        = truncate(shipping_address[:country], 50)
  #         form[:ship_to_zip]            = truncate(shipping_address[:zip], 10)
  #       end
  #     end
  #
  #     def add_verification(form, options)
  #       form[:verify] = 'Y' if options[:verify]
  #     end
  #
  #     def add_test_mode(form, options)
  #       form[:test_mode] = 'TRUE' if options[:test_mode]
  #     end
  #
  #     def add_partial_shipment_flag(form, options)
  #       form[:partial_shipment_flag] = 'Y' if options[:partial_shipment_flag]
  #     end
  #
  #     def add_ip(form, options)
  #       form[:cardholder_ip] = options[:ip] if options.has_key?(:ip)
  #     end
end
