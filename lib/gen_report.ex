defmodule GenReport do
  alias GenReport.Parser

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(initial_report(), fn parsed_line, report ->
      building_report([parsed_line, report])
    end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  defp building_report([_parsed_line, _report] = data) do
    data
    |> all_hours()
    |> hours_per_month()
    |> hours_per_year()
  end

  defp all_hours([
         [name, work_hours, _day, _month, _year] = data,
         %{"all_hours" => employees} = report
       ]) do
    result =
      case Map.has_key?(employees, name) do
        true -> Map.put(employees, name, employees[name] + work_hours)
        false -> Map.put(employees, name, work_hours)
      end

    [data, %{report | "all_hours" => result}]
  end

  def hours_per_month([
        [name, work_hours, _day, month, _year] = data,
        %{"hours_per_month" => employees} = report
      ]) do
    result =
      Map.update(employees, name, %{month => work_hours}, fn existing_value ->
        case Map.has_key?(existing_value, month) do
          true ->
            %{existing_value | month => existing_value[month] + work_hours}

          false ->
            Map.put(existing_value, month, work_hours)
        end
      end)

    [data, %{report | "hours_per_month" => result}]
  end

  def hours_per_year([
        [name, work_hours, _day, _month, year],
        %{"hours_per_year" => employees} = report
      ]) do
    result =
      Map.update(employees, name, %{year => work_hours}, fn existing_value ->
        case Map.has_key?(existing_value, year) do
          true ->
            %{existing_value | year => existing_value[year] + work_hours}

          false ->
            Map.put(existing_value, year, work_hours)
        end
      end)

    %{report | "hours_per_year" => result}
  end

  def initial_report() do
    %{
      "all_hours" => %{},
      "hours_per_month" => %{},
      "hours_per_year" => %{}
    }
  end
end
