defmodule CommerceCure.Response do
  alias CommerceCure.Http.Status

  @type body  :: map | list
  @type error :: map | list

  def process_status_code(200), do: :ok
  def process_status_code(code), do: {:error, Status.reason_phrase(code)}

  def process_body(body) do
    {:ok, body}
  end

  def succeed?(body, error)
  def succeed?(_, 0), do: true
  def succeed?(_, nil), do: true
  def succeed?(_, []), do: true
  def succeed?(_, _), do: false

  @callback new(Tesla.Env.t) :: map
  @callback process_error(body) :: {:ok, error} | {:error, reason :: String.t}
  @callback succeed?(body, error) :: boolean

  defmacro __using__(_) do
    quote do
      @type t :: %__MODULE__{
        succeed?: boolean,
        body:     CommerceCure.Response.body,
        error:    CommerceCure.Response.error
      }

      @behaviour CommerceCure.Response
      @enforce_keys [:succeed?, :body, :error]
      defstruct     [:succeed?, :body, :error]

      @spec new(Tesla.Env.t) :: {:ok, t} | {:error, String.t}
      def new(%{status: code, body: body, headers: _headers}) do
        with :ok <- CommerceCure.Response.process_status_code(code),
             {:ok, body} <- process_body(body),
             {:ok, error} <- process_error(body)
        do
          {:ok, %__MODULE__{
            succeed?: succeed?(body, error),
            body: body,
            error: error
          }}
        end
      end

      @spec new!(Tesla.Env.t) :: t | nil
      def new!(terms) do
        case new(terms) do
          {:ok, response} ->
            response
          {:error, reason} ->
            raise ArgumentError, "#{inspect terms} has error of #{inspect reason}"
        end
      end

      def process_body(body) do
        CommerceCure.Response.process_body(body)
      end

      def succeed?(body, error) do
        CommerceCure.Response.succeed?(body, error)
      end

      defoverridable process_body: 1, succeed?: 2
    end
  end
end
