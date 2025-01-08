defmodule MyProject.APIreq do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{interval: 5000}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_work(state.interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do

    case make_api_request() do
      {:ok, data} ->
        IO.inspect(data)

      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end

    schedule_work(state.interval)
    {:noreply, state}
  end

  defp make_api_request do
    url = "https://jsonplaceholder.typicode.com/todos/1"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        handle_response(body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP Error: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp handle_response(body) do
    case Jason.decode(body) do
      {:ok, decoded_data} ->
        {:ok, decoded_data}

      {:error, _reason} ->
        {:error, "Failed to decode JSON"}
    end
  end

  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval)
  end
end
