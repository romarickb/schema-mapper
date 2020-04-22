# SchemaMapper

SchemaMapper comes from the [Lonestar ElixirConf 2019 talk of Greg Vaughn](https://www.youtube.com/watch?v=k_xDi7zAcNM).
The code base is from his slides.

## How it works

When create a schema from a raw map and be sure there is no error, use `SchemaMapper` module like the following example

Note: you don't need to override `required_fields/0`. By default, all fields will be optionals.

```elixir
  defmodule Performer do
    use SchemaMapper

    embedded_schema do
      field(:name, :string)
      field(:age, :integer)
    end

    def required_fields do
      ~w(name)a
    end
  end

  defmodule Event do
    use SchemaMapper

    embedded_schema do
      field(:name, :string)
      field(:occurs_at, :naive_datetime)
      embeds_one(:performer, Performer)
    end

    def required_fields do
      ~w(name performer)a
    end
  end
```

```shell
iex(1)> raw_map = %{
...(1)>       "name" => "Elixir Big Band",
...(1)>       "occurs_at" => "2004-10-19 10:23:54",
...(1)>       "performer" => %{
...(1)>         "name" => "John Doe",
...(1)>         "age" => "21"
...(1)>       }
...(1)>     }
iex(2)> Event.new(raw_map)

{:ok,
 %Event{
   name: "Elixir Big Band",
   occurs_at: ~N[2004-10-19 10:23:54],
   performer: %Performer{age: 21, name: "John Doe"}
 }}
```
