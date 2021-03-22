defmodule Report do
  alias Report.Parser
  @keys ["name", "hours", "day", "month", "year"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.to_list()
  end

  def full_report(filename \\ "gen_report.csv") do
    values = build(filename)
    all = all_hours(values)
    map = group_data(values)
    keys = get_keys(map) # header_keys
    by_month = reports_by(map, 3)
    by_year = reports_by(map, 4)

    %{all_hours: all,hours_per_month: add_header_keys(keys, by_month), hours_per_year: add_header_keys(keys, by_year)}
  end

  def all_hours(values) do
    map = values
    |> build_map()
    Enum.reduce(values, map, fn [name, hours | _rest], acc -> Map.put(acc, name, acc["#{name}"] + hours) end)
  end

  def build_map(values, position \\ 0) do
    values
    |> Enum.reduce(%{}, fn element, acc -> Map.put(acc, Enum.at(element, position), 0) end)
  end

  def group_data(values) do
    values
    |> Stream.map(fn e -> month_to_name(e, Enum.at(e, 3)) end)
    |> Enum.group_by(&Enum.at(&1, 0))
  end

  defp month_to_name(list, month) do
    list
    |> List.update_at(3, fn _ -> String.replace(month, month, DateHelpers.month_to_string(month)) end)
  end

  defp get_keys(map), do: Map.keys(map)

  def reports_by(map, key_position) do
    keys = get_keys(map)
    Enum.map(keys, fn key ->
      person = map["#{key}"]
      build = build_map(person, key_position)
      Enum.reduce(person, build, fn e, acc -> Map.put(acc, Enum.at(e, key_position), Enum.at(e, 1) + acc["#{Enum.at(e, key_position)}"]) end)
     end)
  end

  defp add_header_keys(keys, list) do
    Enum.zip(keys, list)
    |> Enum.into(%{})
  end
end
