defmodule AxonCore.PydanticHTTPClient do
  @moduledoc """
  HTTP client for making requests to the Pydantic agent.
  """

  require Logger
  alias AxonCore.JSONCodec

  def post(url, body) when is_binary(url) do
    headers = [{"content-type", "application/json"}]
    
    case Finch.build(:post, url, headers, JSONCodec.encode!(body))
         |> Finch.request(AxonFinch) do
      {:ok, response} ->
        {:ok, %{status: response.status, body: JSONCodec.decode!(response.body)}}
      
      {:error, reason} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def stream_request(url, body, _opts \\ []) do
    headers = [{"content-type", "application/json"}]
    
    case Finch.build(:post, url, headers, JSONCodec.encode!(body))
         |> Finch.request(AxonFinch) do
      {:ok, response} when response.status in 200..299 ->
        {:ok, response.body}
      
      {:ok, response} ->
        {:error, {:http_error, response.status, response.body}}
      
      {:error, reason} ->
        Logger.error("HTTP request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
