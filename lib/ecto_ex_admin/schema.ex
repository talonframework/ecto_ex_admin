defmodule ExAdmin.Schema.Adapters.Ecto do
  @moduledoc """
  Implements the ExAdmin.Scheam.Adapters behaviour.

  Add support for Ecto in ExAdin. 
  """
  @behaviour ExAdmin.Schema.Adapters

  @doc """
  Retrieve the primay key of a query, schema module, or a schema struct.
  
  ## Examples

      iex> primary_key from b in Blog
      :id
      iex> primary_key Blog
      :id
      iex> primary_key %Blog{}
      :id
  """
  def primary_key(%Ecto.Query{from: {_, mod}}) do
    primary_key mod
  end

  def primary_key(module) when is_atom(module) do
    case module.__schema__(:primary_key) do
      [] -> nil
      [key | _] -> key
    end
  end

  def primary_key(resource) do
    cond do
      Map.get(resource, :__struct__, false) ->
        primary_key resource.__struct__
      true -> :id
    end
  end

  @doc """
  Retrieve the id value of a schema struct.

      iex> get_id %Tag{name: "elixir"}
      "elixir"
  """
  def get_id(resource) do
    Map.get(resource, primary_key(resource))
  end

  @doc """
  Retrive type of a schem field.

  ## Examples

      iex> type((from u in User), :email)
      :string

      iex> type(User, :id)
      :binary_id

      iex> type(%User{}, :login_count)
      :integer
      
  """
  def type(%Ecto.Query{from: {_, mod}}, key), do: type(mod, key)
  def type(module, key) when is_atom(module) do
    module.__schema__(:type, key)
  end
  def type(resource, key), do: type(resource.__struct__, key)

  @doc """
  TBD  
  """
  def get_intersection_keys(resource, assoc_name) do
    resource_model = resource.__struct__
    %{through: [link1, link2]} = resource_model.__schema__(:association, assoc_name)
    intersection_model = resource |> Ecto.build_assoc(link1) |> Map.get(:__struct__)
    [
      resource_key: resource_model.__schema__(:association, link1).related_key,
      assoc_key: intersection_model.__schema__(:association, link2).owner_key
    ]
  end
end