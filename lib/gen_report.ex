defmodule GenReport do
  alias GenReport.Parser

  @devs [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_hours(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  def build_from_many, do: {:error, "Insira uma lista com os nomes dos arquivo"}

  defp sum_hours(
         [dev, hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         }
       ) do
    all_hours = Map.put(all_hours, dev, all_hours[dev] + hours)
    hours_per_month = calc_by(hours_per_month, dev, hours, month)
    hours_per_year = calc_by(hours_per_year, dev, hours, year)

    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    %{
      "all_hours" => _all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    } = report_acc()

    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month =
      Enum.reduce(@devs, hours_per_month, fn dev, report ->
        Map.put(report, dev, merge_maps(hours_per_month1[dev], hours_per_month2[dev]))
      end)

    hours_per_year =
      Enum.reduce(@devs, hours_per_year, fn dev, report ->
        Map.put(report, dev, merge_maps(hours_per_year1[dev], hours_per_year2[dev]))
      end)

    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp report_acc do
    months = Enum.into(@months, %{}, &{&1, 0})
    years = Enum.into(2016..2020, %{}, &{&1, 0})

    all_hours = Enum.into(@devs, %{}, &{&1, 0})
    hours_per_month = Enum.into(@devs, %{}, &{&1, months})
    hours_per_year = Enum.into(@devs, %{}, &{&1, years})

    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp calc_by(hours_map, dev, hours, option) do
    result =
      hours_map
      |> Map.get(dev)
      |> Map.update(option, 0, &(&1 + hours))

    %{hours_map | dev => result}
  end

  defp build_reports(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
