defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game
  alias Memory.BackupAgent

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.reset()
      BackupAgent.put(name, game)
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      IO.inspect socket
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("flip", %{ "panel_index" => ll }, socket) do
    name = socket.assigns[:name]
    game = Game.flip(socket.assigns[:game], ll)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    IO.inspect game
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("flip_back", _map, socket) do
    name = socket.assigns[:name]
    game = Game.flip_back(socket.assigns[:game], ll)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    IO.inspect game
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("reset", _map, socket) do
    name = socket.assigns[:name]
    game = Game.reset()
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
