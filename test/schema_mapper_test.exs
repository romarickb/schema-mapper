defmodule SchemaMapperTest do
  use ExUnit.Case
  doctest SchemaMapper

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

  test "new/1 return new mapped schema when there is no error" do
    raw_map = %{
      "name" => "Elixir Big Band",
      "occurs_at" => "2004-10-19 10:23:54",
      "performer" => %{
        "name" => "John Doe",
        "age" => "21"
      }
    }

    {:ok, event} = Event.new(raw_map)
    assert event.name == "Elixir Big Band"
    assert event.occurs_at == ~N[2004-10-19 10:23:54]
    assert event.performer.name == "John Doe"
    assert event.performer.age == 21
  end

  test "new/1 returns error when field can't be mapped" do
    raw_map = %{
      "name" => "Elixir Big Band",
      "occurs_at" => "2004-10-19 10:23:54",
      "performer" => %{
        "name" => "John Doe",
        "age" => "twenty one"
      }
    }

    {:error, changeset} = Event.new(raw_map)

    assert changeset.changes.performer.errors === [
             age: {"is invalid", [type: :integer, validation: :cast]}
           ]
  end

  test "new/1 returns error when required fields are missing" do
    {:error, changeset} = Event.new(%{})

    assert length(changeset.errors) === 2
    assert Enum.member?(changeset.errors, {:name, {"can't be blank", [validation: :required]}})

    assert Enum.member?(
             changeset.errors,
             {:performer, {"can't be blank", [validation: :required]}}
           )
  end

  test "new/1 returns error when required embedded field is missing" do
    raw_map = %{
      "name" => "Elixir Big Band",
      "occurs_at" => "2004-10-19 10:23:54",
      "performer" => %{
        "age" => "21"
      }
    }

    {:error, changeset} = Event.new(raw_map)

    assert changeset.changes.performer.errors === [
             {:name, {"can't be blank", [validation: :required]}}
           ]
  end
end
