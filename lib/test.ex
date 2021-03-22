defmodule Test do
  alias Report
  alias Report.Parser
  # result
  # |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

  # {:ok, result}
  def test do
    ["part_1.csv", "part-2.csv", "part_3.csv"]
    |> build_from_many()
  end

  def build_from_many(file_names) do
    read_async(file_names)
  end

  def read_async(file_name) do
    [result] =
    file_name
    |> Task.async_stream(&Report.build/1)
    |> Enum.map(fn {:ok, result} -> result end)
    result
  end

  # def sum_values(list1, file) do
  #   list = read_async(file)
  #   [list| list1]
  # end
end
