defmodule CommerceCure.Config do
  @req [:url, :username, :password, :cert_file]

  @spec ensure_properly_loaded(Keyword.t) :: :ok | {:error. list}
  def ensure_properly_loaded(keyword)

  def ensure_properly_loaded(nil) do
    {:error, "configuration is missing."}
  end

  def ensure_properly_loaded(keyword) do
    case Enum.reject(@req, &Keyword.get(keyword, &1)) do
      [] ->
        :ok
      reject ->
        {:error, "requires :#{Enum.join(reject, ", :")}"}
    end
  end
end
