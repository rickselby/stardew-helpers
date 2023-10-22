module ForageHelper
  def spot_name(spot)
    "(#{spot[:x]}, #{spot[:y]}): #{spot[:name]}"
  end
end
