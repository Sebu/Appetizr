

def check_scanner_string(scan)
  if m = /^-[cC]([0-9]{2,3})-$/.match(scan)
    return :key, "c#{m[1]}"
  elsif m = /^16900([0-9]{6})[0-9]{1}$/.match(scan)
    return :matrikel, m[1]
  elsif m = /'^UP-([A-Z]{1})-[a-zA-Z0-9]+-[0-9]{4}$/.match(scan)
    return :card, m[1]
  else
    return :other, "du_affe"
  end
end
