util.init_hosted()

local json = require "json"
local services = {}
local rotate_before = nil
local transform = nil
local ack_image = resource.load_image("ack.png")

local c_hard = {}
c_hard[0] = resource.create_colored_texture(0,   0.666, 0,   1)
c_hard[1] = resource.create_colored_texture(0.8, 0.466, 0,   1)
c_hard[2] = resource.create_colored_texture(0.8, 0,     0,   1)
c_hard[3] = resource.create_colored_texture(0.8, 0,     0.8, 1)

local c_soft = {}
c_soft[0] = resource.create_colored_texture(0,   0.666, 0,   0.6)
c_soft[1] = resource.create_colored_texture(0.8, 0.466, 0,   0.75)
c_soft[2] = resource.create_colored_texture(0.8, 0,     0,   0.6)
c_soft[3] = resource.create_colored_texture(0.8, 0,     0.8, 0.6)

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
    end

    if rotate_before == 90 or rotate_before == 270 then
        real_width = NATIVE_HEIGHT
        real_height = NATIVE_WIDTH
    else
        real_width = NATIVE_WIDTH
        real_height = NATIVE_HEIGHT
    end

    if CONFIG.instance_name ~= "" then
        titlebar = CONFIG.instance_name .. " - " .. services.prettytime
    else
        titlebar = servics.prettytime
    end

    local title_width = CONFIG.header_font:width(titlebar, CONFIG.output_size)

    transform()
    CONFIG.background_color.clear()
    CONFIG.header_font:write(real_width/2-title_width/2, CONFIG.output_size*0.5, titlebar, CONFIG.output_size, 1,1,1,1)

    local y = CONFIG.output_size*2
    for idx, serv in ipairs(services.services) do
        local host_font_size = CONFIG.header_size
        local service_font_size = CONFIG.header_size
        local margin = math.min(CONFIG.output_size, 20)
        local header_width = real_width-20-margin*2
        local host_width = CONFIG.header_font:width(serv.host, host_font_size)
        local service_width = CONFIG.header_font:width(serv.service, service_font_size)
        local my_height = (#serv.output*CONFIG.output_size*1.5) + margin*3

        if serv.ack then
            header_width = header_width - margin - host_font_size
        end

        if host_width + service_width > header_width then
            -- two-line output, if possible
            while CONFIG.header_font:width(serv.host, host_font_size) > header_width do
                host_font_size = host_font_size -1
            end
            while CONFIG.header_font:width(serv.service, service_font_size) > header_width do
                service_font_size = service_font_size -1
            end
            my_height = my_height + host_font_size + margin + service_font_size
        else
            my_height = my_height + CONFIG.header_size
        end

        if serv.type == 0 then
            c_soft[serv.state]:draw(0, y, real_width, y+my_height)
        else
            c_hard[serv.state]:draw(0, y, real_width, y+my_height)
        end

        y = y + margin

        local service_x = real_width - margin - CONFIG.header_font:width(serv.service, service_font_size)

        if serv.ack then
            ack_image:draw(
                real_width - margin - service_font_size, y,
                real_width - margin, y + service_font_size
            )
            service_x = service_x - service_font_size - margin
        end

        if host_width + service_width > header_width then
            CONFIG.header_font:write(margin, y, serv.host, host_font_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][2],1)
            y = y + host_font_size + margin
            CONFIG.header_font:write(service_x, y, serv.service, service_font_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)
            y = y + service_font_size + margin
        else
            CONFIG.header_font:write(margin, y, serv.host, host_font_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][2],1)
            CONFIG.header_font:write(service_x, y, serv.service, service_font_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)
            y = y + CONFIG.header_size + margin
        end

        for idx, line in ipairs(serv.output) do
            CONFIG.output_font:write(margin, y, line, CONFIG.output_size, c_text[serv.state][1],c_text[serv.state][2],c_text[serv.state][3],1)
            y = y + CONFIG.output_size * 1.5
        end

        y = y + margin + 2

        if y > real_height then
            break
        end
    end
end
