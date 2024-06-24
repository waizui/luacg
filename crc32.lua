local crc32 = {}

local crc32_table = {}

local function crc32_init()
    local polynomial = 0xEDB88320
    for i = 0, 255 do
        local crc = i
        for _ = 1, 8 do
            if crc & 1 ~= 0 then
                crc = (crc >> 1) ~ polynomial
            else
                crc = crc >> 1
            end
        end
        crc32_table[i] = crc
    end
end

crc32_init()

function crc32.crc32(input)
    local crc = 0xFFFFFFFF
    for i = 1, #input do
        local byte = input:byte(i)
        crc = (crc >> 8) ~ crc32_table[(crc & 0xFF) ~ byte]
    end
    return ~crc & 0xFFFFFFFF
end

return crc32

