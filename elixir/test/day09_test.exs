defmodule Day09Test do
  use ExUnit.Case
  doctest Day09

  test "day09" do
    input1 = """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
    input2 = """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """
    assert Day09.problem1(input1, :io) == 13
    assert Day09.problem2(input1, :io) == 1
    assert Day09.problem2(input2, :io) == 36
  end
end
