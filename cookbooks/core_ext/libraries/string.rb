class String
  # convert strings like 64M, 2G etc to their byte value
  def to_bytes
    /^(\d+)([KMG])?$/ =~ self
    num, unit = $1.to_i, $2

    case unit
    when "K"
      num *= 1024
    when "M"
      num *= 1024*1024
    when "G"
      num *= 1024*1024*1024
    end
  end
end
