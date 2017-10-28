defmodule CommerceCure do
  alias CommerceCure.Request

  @type action :: :purchase | :authorize | :capture | :void | :refund |
                  :verify | :store | :unstore | atom

  @spec purchase(Money.t, PaymentCard.t, map, list) :: map
  def purchase(money, payment_card, info \\ %{}, opts \\ [])
  def purchase(money, payment_card, _info, _opts) do
    %{}
    |> Request.put(money)
    |> Request.put(payment_card)
  end

  @callback purchase(Money.t, PaymentCard.t, info :: map, opts :: Keyword.t)  :: String.t
  @callback authorize(Money.t, PaymentCard.t, info :: map, opts :: Keyword.t) :: String.t
  @callback capture(Money.t, Authorization.t, info :: map, opts :: Keyword.t) :: String.t
  @callback void(Transaction.t, info :: map, opts :: Keyword.t) :: String.t
  @callback refund(Money.t, Transaction.t, info :: map, opts :: Keyword.t) :: String.t
  @callback verify(PaymentCard.t, info :: map, opts :: Keyword.t) :: String.t

  @callback store(PaymentCard.t, opts :: Keyword.t) :: String.t
  @callback unstore(Transaction.t, opts :: Keyword.t) :: String.t

  @callback send(any) :: Tesla.Env.t
  @callback client() :: Tesla.Env.client

  @optional_callbacks store: 2, unstore: 2

  defmacro __using__([otp_app: otp_app]) do
    quote bind_quoted: [otp_app: otp_app] do
      use Tesla
      adapter :hackney
      plug Tesla.Middleware.Headers, %{"user-agent" => "#{%CommerceCure.UserAgent{}}"}

      @behaviour CommerceCure
      @otp_app otp_app

      @config Application.get_env(@otp_app, __MODULE__)

      case CommerceCure.Config.ensure_properly_loaded @config do
        {:error, message} ->
          raise RuntimeError, "#{inspect @otp_app}, #{inspect __MODULE__} #{message}"
        :ok -> nil
      end

      def config, do: @config

      def get_config(key, default \\ nil) do
        Keyword.get(@config, key, default)
      end

      def fetch_config(key) do
        Keyword.get(@config, key) || raise ArgumentError, "#{inspect @otp_app}, #{inspect __MODULE__} requires #{key}"
      end

      def send(body) do
        __MODULE__.post(client(), fetch_config(:url), body, [ssl: [certfile: fetch_config(:cert_file)]])
      end

      def client do
        Tesla.build_client []
      end

      @overrideable CommerceCure
    end
  end
end
