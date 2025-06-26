defmodule Servy.Plugins do
  @moduledoc "Helper functions"

  # A single expression in the function body. Hence can be written on one line without an end
  # IO.inspect writes to stdout, and in addition also returns the value passed to it.
  # Hence, can be safely used in a pipeline.
  def log(conv), do: IO.inspect conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    IO.puts "Rewriting wildlife to wildthings"
    # Return an updated conv with the path changed
    # This is a new map with the same keys as conv, but with the path changed
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> bear_id} = conv) do
    # Bear with query parameter.
    # Modify it to route to bear detail.
    IO.puts "Rewriting bear query param to bear detail"
    %{conv | path: "/bears/" <> bear_id}
  end

  # A function clause that matches when the path is not "/wildlife"
  # This is a default catch-all function clause.
  # Ordering is important in Elixir. The first matching function clause is executed.
  # As this is a generic function, it will match any conv that does not match the previous clause.
  def rewrite_path(conv), do: conv


  def track(%{status: 404} = conv) do
    IO.puts ("Warning: 404 for #{conv.path}")
    conv
  end

  # Default function clause that matches non 404 statuses
  def track(conv), do: conv
end
