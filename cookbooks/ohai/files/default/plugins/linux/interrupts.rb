Ohai.plugin(:Interrupts) do
  provides "interrupts"

  collect_data do
    interrupts Mash.new
    IO.readlines("/proc/interrupts").each do |line|
      parts = line.split
          Ohai::Log.debug(parts.inspect)
      number = parts.first.gsub(/:/, '').to_i
      next unless number > 0
      interrupts[parts.last] = number
    end
  end
end
