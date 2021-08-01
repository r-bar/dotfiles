function OnBattery()
  silent! let f = readfile('/sys/class/power_supply/AC/online')
  return f == ['0']
endfunction
