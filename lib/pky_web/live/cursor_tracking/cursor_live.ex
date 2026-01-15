defmodule PkyWeb.Live.CursorTracking.CursorLive do
  @moduledoc """

  """

  use PkyWeb, :live_view

  alias PkyWeb.Live.CursorTracking.CursorUtils
  alias Phoenix.PubSub

  @topic "cursor_tracking"

  def mount(_params, _session, socket) do
    # Assign a unique ID and random attributes to the current user
    user_id = Ecto.UUID.generate()
    color = CursorUtils.random_color()
    name = CursorUtils.random_name()

    if connected?(socket) do
      # Subscribe to the global cursor topic
      PubSub.subscribe(Pky.PubSub, @topic)
    end

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:color, color)
     |> assign(:name, name)
     |> assign(:cursors, %{})} # Map to store other users' positions
  end

  # Handle the event from the JavaScript Hook
  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    payload = %{
      id: socket.assigns.user_id,
      x: x,
      y: y,
      color: socket.assigns.color,
      name: socket.assigns.name
    }

    # Broadcast to everyone EXCEPT the current user (self)
    PubSub.broadcast_from!(Pky.PubSub, self(), @topic, {:cursor_update, payload})
    {:noreply, socket}
  end

  # Handle the broadcasted message from other users
  def handle_info({:cursor_update, payload}, socket) do
    # Update the map of cursors.
    # We use the user's ID as the key to overwrite their previous position.
    updated_cursors = Map.put(socket.assigns.cursors, payload.id, payload)
    {:noreply, assign(socket, :cursors, updated_cursors)}
  end


end
