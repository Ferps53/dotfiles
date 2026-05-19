local socket = require("socket")
print(socket.dns.gethostname())
local hostname = socket.dns.gethostname()

if hostname == 'ferps-home' then
  hl.monitor({
    output = 'eDP-1',
    position = '1920x0',
    scale = 1,
    mode = '1920x1080@165.01'
  })
  hl.monitor({
    output = 'HDMI-A-1',
    position = '0x0',
    scale = '1',
    mode = '1920x1080@60.0000',
  })
elseif hostname == 'ferps-work' then
  hl.monitor({
    output = 'HDMI-A-1',
    position = '0x0',
    scale = '1',
    mode = '1920x1080@60.0000',
  })
end
