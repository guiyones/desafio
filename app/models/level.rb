Level = Data.define(:number, :xp_into, :xp_needed) do
  def self.threshold(number)
    25 * number * (number - 1)
  end

  def self.for(xp)
    number = 1
    number += 1 while threshold(number + 1) <= xp

    new(number: number, xp_into: xp - threshold(number), xp_needed: 50 * number)
  end
end
