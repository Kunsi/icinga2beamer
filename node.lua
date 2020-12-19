util.init_hosted()

local json = require "json"
local services = {}
local host_width = 0
local time_width = 0
local rotate_before = nil
local transform = nil

local c_hard = {}
c_hard[0] = resource.create_colored_texture(0,   0.6, 0,   1)
c_hard[1] = resource.create_colored_texture(0.8, 0.9, 0,   1)
c_hard[2] = resource.create_colored_texture(0.8, 0,   0,   1)
c_hard[3] = resource.create_colored_texture(0.6, 0,   0.7, 1)

local c_soft = {}
c_soft[1] = resource.create_colored_texture(0.3, 0.4, 0,   1)
c_soft[2] = resource.create_colored_texture(0.3, 0,   0,   1)
c_soft[3] = resource.create_colored_texture(0.3, 0,   0.4, 1)

local c_text = {}
c_text[0] = {1, 1, 1}
c_text[1] = {0, 0, 0}
c_text[2] = {1, 1, 1}
c_text[3] = {1, 1, 1}

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.file_watch("services.json", function(content)
    services = json.decode(content)
    host_width = 0

    for idx, service in ipairs(services.services) do
        host_width = math.max(host_width, CONFIG.font:width(service.host, 50))
    end

    time_width = CONFIG.font:width(services.prettytime, 30)
end)

local white = resource.create_colored_texture(1,1,1,1)
local base_time = N.base_time or 0

function node.render()
    if rotate_before ~= CONFIG.rotate then
        transform = util.screen_transform(CONFIG.rotate)
        rotate_before = CONFIG.rotate

        if rotate_before == 90 or rotate_before == 270 then
            real_width = NATIVE_HEIGHT
            real_height = NATIVE_WIDTH
        else
            real_width = NATIVE_WIDTH
            real_height = NATIVE_HEIGHT
        end
    end

    transform()
    CONFIG.background_color.clear()
    CONFIG.font:write(real_width/2-time_width/2, 10, services.prettytime, 30, 1,1,1,1)

    local y = 50
    for idx, serv in ipairs(services.services) do
        my_height = (#serv.output*40)+90

        if serv.type == 0 then
            c_soft[serv.state]:draw(0, y, NATIVE_WIDTH, y+my_height)
        else
            c_hard[serv.state]:draw(0, y, NATIVE_WIDTH, y+my_height)
        end

        y = y+20

        CONFIG.font:write(10, y, serv.host, 50, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][2],1)
        CONFIG.font:write(host_width+40, y, serv.service, 50, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)

        y = y+60

        for idx, line in ipairs(serv.output) do
            CONFIG.font:write(host_width+40, y, line, 30, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)
            y = y+40
        end

        y = y+12
    end
end
