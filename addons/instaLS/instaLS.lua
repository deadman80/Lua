--Copyright (c) 2015, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'instaLS'
_addon.version = 0.151123
_addon.author = 'Byrth'

flag=false
chatmode = false
chatcolor = false
message = false

windower.register_event('zone change',function()
    flag=false
end)

windower.register_event('incoming chunk',function(id)
    if id == 0x1D then
        flag = true
    end
end)

windower.register_event('outgoing chunk',function(id,org,mod,inj)
    if id == 0xB5 and not inj and chatmode and mod:byte(5) == 0 then -- and org:unpack('z',7) == message
        -- Not injected, message currently queued
        local outpack = mod:sub(1,4)..string.char(chatmode)..mod:sub(6)
        chatmode = false
        return outpack
    end
end)

windower.register_event('incoming text',function(org, mod, col)
    if message and chatcolor and string.find(org,message) then
        local a,b = string.find(mod,windower.ffxi.get_player().name)
        mod = mod:sub(1,a-1)..'['..(chatcolor==6 and '1' or '2')..']<'..mod:sub(a,b)..'>'..mod:sub(b+3)
        local retarr = {mod, chatcolor}
        chatcolor = false
        return unpack(retarr)
    end
end)

windower.register_event('outgoing text',function(org,mod,bool)
    if bool or flag then return end
    if mod:sub(1,3) == '/l ' then
        chatmode = 0x05
        chatcolor = 6
        message = mod:sub(4)
    elseif mod:sub(1,11) == '/linkshell ' then
        chatmode = 0x05
        chatcolor = 6
        message = mod:sub(12)
    elseif mod:sub(1,4) == '/l2 ' then
        chatmode = 0x1B
        chatcolor = 213
        message = mod:sub(5)
    elseif mod:sub(1,12) == '/linkshell2 ' then
        chatmode = 0x1B
        chatcolor = 213
        message = mod:sub(13)
    end
    
    if chatmode and message then
        return '/s '..message
    end
end)