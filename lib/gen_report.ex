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

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_hours(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp sum_hours(
         [dev, hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         } = report
       ) do
    all_hours = Map.put(all_hours, dev, all_hours[dev] + hours)
    hours_per_month = calc_by(hours_per_month, dev, hours, month)
    hours_per_year = calc_by(hours_per_year, dev, hours, year)

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => hours_per_month,
        "hours_per_year" => hours_per_year
    }
  end

  defp report_acc do
    months = Enum.into(@months, %{}, &{&1, 0})
    years = Enum.into(@years, %{}, &{&1, 0})

    all_hours = Enum.into(@devs, %{}, &{&1, 0})
    hours_per_month = Enum.into(@devs, %{}, &{&1, months})
    hours_per_year = Enum.into(@devs, %{}, &{&1, years})

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp calc_by(hours_map, dev, hours, option) do
    result =
      hours_map
      |> Map.get(dev)
      |> Map.update(option, 0, &(&1 + hours))

    %{hours_map | dev => result}
  end
end
