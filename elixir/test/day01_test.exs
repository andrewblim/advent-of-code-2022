defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "day01" do
    input = """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """
    assert Day01.problem1(input, :io) == 24000
    assert Day01.problem2(input, :io) == 45000
  end
end
