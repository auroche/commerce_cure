defmodule CommerceCure.UserAgent do
  @config    Mix.Project.config()
  @publisher @config |> Keyword.fetch!(:app)
  @client    :tesla
  @language  :elixir
  @version        @config |> Keyword.fetch!(:version)
  @client_version @config |> Keyword.fetch!(:deps) |> Keyword.fetch!(@client)
  @lang_version   @config |> Keyword.fetch!(:elixir)

  defstruct publisher:      @publisher |> Atom.to_string() |> Macro.camelize(),
            version:        @version |> String.replace(" ", ""),
            client:         @client |> Atom.to_string() |> Macro.camelize(),
            client_version: @client_version |> String.replace(" ", ""),
            lang:           @language |> Atom.to_string() |> Macro.camelize(),
            lang_version:   @lang_version |> String.replace(" ", "")

  def new do
    %__MODULE__{}
  end

  def to_string(user_agent \\ %__MODULE__{})
  def to_string(%{
    publisher: publisher,
    version: version,
    client: client,
    client_version: client_version,
    lang: lang,
    lang_version: lang_version})
  do
    "#{publisher}/#{version} #{client}/#{client_version} #{lang}/#{lang_version}"
  end

  defimpl String.Chars do
    def to_string(user_agent) do
      CommerceCure.UserAgent.to_string user_agent
    end
  end
end
