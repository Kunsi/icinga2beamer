util.init_hosted()

local json = require "json"
local services = {}
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

    if CONFIG.instance_name ~= "" then
        titlebar = CONFIG.instance_name .. " - " .. services.prettytime
    else
        titlebar = servics.prettytime
    end

    local title_width = CONFIG.header_font:width(titlebar, CONFIG.output_size)
    local host_width = 0

    transform()
    CONFIG.background_color.clear()
    CONFIG.header_font:write(real_width/2-title_width/2, CONFIG.output_size*0.5, titlebar, CONFIG.output_size, 1,1,1,1)

    for idx, service in ipairs(services.services) do
        host_width = math.max(host_width, CONFIG.header_font:width(service.host, CONFIG.header_size))
    end

    local y = CONFIG.output_size*2
    for idx, serv in ipairs(services.services) do
        host_size = CONFIG.header_size
        svc_size = CONFIG.header_size

        while CONFIG.header_font:width(serv.host, host_size) > real_width/2-20 do
            host_size = host_size - 2
        end
        while CONFIG.header_font:width(serv.service, svc_size) > real_width/2-50 do
            svc_size = svc_size - 2
        end

        margin = math.min(CONFIG.output_size, 20)
        my_height = (#serv.output*CONFIG.output_size*1.5)+margin*2+CONFIG.header_size+CONFIG.output_size*0.5
        indent = math.min(host_width, real_width/2)+40

        if serv.type == 0 then
            c_soft[serv.state]:draw(0, y, NATIVE_WIDTH, y+my_height)
        else
            c_hard[serv.state]:draw(0, y, NATIVE_WIDTH, y+my_height)
        end

        y = y+margin

        CONFIG.header_font:write(10, y, serv.host, host_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][2],1)
        CONFIG.header_font:write(indent, y, serv.service, svc_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)

        y = y+CONFIG.header_size+CONFIG.output_size*0.5

        --debug output
        --CONFIG.font:write(10, y, serv.sort, 10, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][2],1)

        for idx, line in ipairs(serv.output) do
            CONFIG.output_font:write(indent, y, line, CONFIG.output_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)
            y = y+CONFIG.output_size*1.5
        end

        y = y+margin+2

        if y > real_height then
            break
        end
    end
end
