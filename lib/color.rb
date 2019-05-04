def color()
  r_range = [*126..255]
  g_range = [*126..255]
  b_range = [*126..255]
  r = r_range.sample
  g = g_range.sample
  b = b_range.sample
  return "0x#{[r, g, b].map{|i| i.to_s(16) }.join.upcase}"
end
