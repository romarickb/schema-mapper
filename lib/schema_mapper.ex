defmodule SchemaMapper do
  alias Ecto.Changeset

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      @primary_key false

      def new(raw_map), do: unquote(__MODULE__).generic_new(raw_map, __MODULE__)
      def changeset(base, params), do: unquote(__MODULE__).generic_changeset(base, params)
      def required_fields, do: []

      defoverridable(new: 1, changeset: 2, required_fields: 0)
    end
  end

  def generic_new(raw_map, struct_module) do
    struct_module
    |> struct()
    |> struct_module.changeset(raw_map)
    |> Changeset.apply_action(:update)
  end

  def generic_changeset(base, raw_map) do
    struct_module = base.__struct__
    embeds = struct_module.__schema__(:embeds)
    allowed = struct_module.__schema__(:fields) -- embeds

    required_fields = struct_module.required_fields() -- embeds
    required_embeds = struct_module.required_fields() -- allowed

    changeset =
      base
      |> Changeset.cast(raw_map, allowed)
      |> Changeset.validate_required(required_fields)

    Enum.reduce(
      embeds,
      changeset,
      &Changeset.cast_embed(&2, &1, required: &1 in required_embeds)
    )
  end
end
