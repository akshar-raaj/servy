defmodule Maths do
  def add(a, b) do
    a + b
  end

  def divide(_num, 0) do
    IO.puts("Division by 0 not allowed")
    0
  end
  def divide(num, den) do
    num/den
  end
end

# There is a built-in module called `String`, hence we are calling it Str.
defmodule Str do
  def split("") do
    IO.puts("Empty string, not splitting")
  end
  # Return it as-is
  def split("hello world"=sentence) do
    sentence |> IO.inspect
  end
  def split(sentence) do
    sentence |> String.split(" ") |> List.first
  end
end

# There is a built in module called `Map`, hence we are calling it Dictionary.
defmodule Dictionary do
  def print_name(%{name: "Ascend"}) do
    IO.puts "Ascend!"
  end
  def print_name(%{name: name}) do
    IO.puts "Not Ascend!. It is #{name}"
  end
  def print_name(d) do
    IO.puts "Name missing"
    IO.inspect d
  end
end

IO.puts Maths.add(3, 4)
IO.puts Maths.divide(6, 0)

Str.split("")
IO.puts Str.split("akshar raaj")
Str.split("hello world")

m = %{name: "Ascend", hq: "Arlington"}
IO.inspect m
m = %{m | hq: "Hyderabad"}
IO.inspect m

Dictionary.print_name(m)
Dictionary.print_name(%{name: "Sentient"})
Dictionary.print_name("boo")
