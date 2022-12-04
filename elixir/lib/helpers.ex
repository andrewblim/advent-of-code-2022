defmodule Helpers do
  def file_or_io(input, type) do
    case type do
      :file ->
        {:ok, contents} = File.read(input)
        contents
      :io ->
        {:ok, pid} = StringIO.open(input)
        IO.read(pid, :eof)
    end
  end
end
