class Float
  def round_to(x) # spec_me cover_me heckle_me
    (self * 10**x).round.to_f / 10**x
  end

  def ceil_to(x) # spec_me cover_me heckle_me
    (self * 10**x).ceil.to_f / 10**x
  end

  def floor_to(x) # spec_me cover_me heckle_me
    (self * 10**x).floor.to_f / 10**x
  end
end
