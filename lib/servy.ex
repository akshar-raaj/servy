defmodule Servy do

  @moduledoc "A module to try things out as I learn Elixir!"

  def first_token(str) do
    str |> String.split("\n") |> List.first() |> String.split(" ") |> List.first()
  end

  def hello("akshar") do
    "Hello, I am Akshar!"
  end

  def hello(name) do
    "Hello, #{name}! I am a catch all."
  end

  def double(x) do
    x + x
  end

  def four_times(x) do
    x |> double |> double
  end

  def lname(%{name: "akshar"}) do
    "raaj"
  end

  def lname(%{name: "neelima"}) do
    "gupta"
  end

  def lname(map) do
    "unknown"
  end

  def age(map) do
    case map.name do
      "akshar" -> 36
      "neelima" -> 35
      "apaar" -> 6
      "struva" -> 0.1
    end
  end
end

IO.puts Servy.hello("akshar raaj")
IO.puts Servy.first_token("""
GET /wildlife HTTP/1.1
Host: example.com
Accept: */*
User-Agent: Elixir Client
""")

IO.puts Servy.hello("akshar")

IO.puts Servy.hello("neelima")

IO.puts Servy.lname(%{name: "akshar", age: 36})
IO.puts Servy.lname(%{name: "neelima gupta", age: 36})


defmodule Recursy do
  @moduledoc "Demonstrates recursion!"

  @doc "A recursive function, with two function clauses!"
  def loop([head | tail]) do
    IO.puts head
    loop(tail)
  end

  def loop([]) do
    IO.puts "Done!"
  end

  def sum([head | tail], total) do
    total = total + head
    sum(tail, total)
  end

  def sum([], total), do: total

  def triple([head | tail], result) do
    result = result ++ [head * 3]
    triple(tail, result)
  end

  def triple([], result), do: result
end
