FRAMEWORK_ESX = 'es_extended'
FRAMEWORK_QB = 'qb-core'
FRAMEWORK_VRP = 'vrp'
FRAMEWORK_STANDALONE = 'standalone'

-- Auto plug-in framework. See `server/framework.lua` for API.
if GetResourceState(FRAMEWORK_ESX) == 'started' then
    Config.Framework = FRAMEWORK_ESX
    ESX = exports[FRAMEWORK_ESX]:getSharedObject()
elseif GetResourceState(FRAMEWORK_QB) == 'started' then
    Config.Framework = FRAMEWORK_QB
    QBCore = exports[FRAMEWORK_QB]:GetCoreObject()
elseif GetResourceState('vrp') == 'started' then
    Config.Framework = FRAMEWORK_VRP
    if IsDuplicityVersion() then
        Proxy = module("vrp", "lib/Proxy")
        Tunnel = module("vrp", "lib/Tunnel")
        vRPclient = Tunnel.getInterface("vRP", GetCurrentResourceName())
    else
        Proxy = {}
        local proxy_rdata = {}
        local function proxy_callback(rvalues) -- save returned values, TriggerEvent is synchronous
          proxy_rdata = rvalues
        end
        local function proxy_resolve(itable,key)
        local iname = getmetatable(itable).name
        -- generate access function
        local fcall = function(args,callback)
            if args == nil then
              args = {}
            end
        
            TriggerEvent(iname..":proxy",key,args,proxy_callback)
            return table.unpack(proxy_rdata) -- returns
          end
          itable[key] = fcall -- add generated call to table (optimization)
          return fcall
        end
        --- Add event handler to call interface functions (can be called multiple times for the same interface name with different tables)
        function Proxy.addInterface(name, itable)
          AddEventHandler(name..":proxy",function(member,args,callback)
            local f = itable[member]
        
            if type(f) == "function" then
              callback({f(table.unpack(args))}) -- call function with and return values through callback
              -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
            else
              -- print("error: proxy call "..name..":"..member.." not found")
            end
          end)
        end
        function Proxy.getInterface(name)
          local r = setmetatable({},{ __index = proxy_resolve, name = name })
          return r
        end
        -- END PROXY

        ---- TUNNEL CLIENT SIDE VERSION (https://github.com/ImagicTheCat/vRP)
        -- Too bad that require doesn't exist client-side
        -- TOOLS DEF
        Tools = {}

        -- ID generator

        local IDGenerator = {}

        function Tools.newIDGenerator()
        local r = setmetatable({}, { __index = IDGenerator })
        r:construct()
        return r
        end

        function IDGenerator:construct()
        self:clear()
        end

        function IDGenerator:clear()
        self.max = 0
        self.ids = {}
        end

        -- return a new id
        function IDGenerator:gen()
        if #self.ids > 0 then
            return table.remove(self.ids)
        else
            local r = self.max
            self.max = self.max+1
            return r
        end
        end

        -- free a previously generated id
        function IDGenerator:free(id)
        table.insert(self.ids,id)
        end

        -- TUNNEL DEF
        Tunnel = {}

        local function tunnel_resolve(itable,key)
        local mtable = getmetatable(itable)
        local iname = mtable.name
        local ids = mtable.tunnel_ids
        local callbacks = mtable.tunnel_callbacks
        local identifier = mtable.identifier

        -- generate access function
        local fcall = function(args,callback)
            if args == nil then
            args = {}
            end
            
            -- send request
            if type(callback) == "function" then -- ref callback if exists (become a request)
            local rid = ids:gen()
            callbacks[rid] = callback
            TriggerServerEvent(iname..":tunnel_req",key,args,identifier,rid)
            else -- regular trigger
            TriggerServerEvent(iname..":tunnel_req",key,args,"",-1)
            end

        end

        itable[key] = fcall -- add generated call to table (optimization)
        return fcall
        end

        -- bind an interface (listen to net requests)
        -- name: interface name
        -- interface: table containing functions
        function Tunnel.bindInterface(name,interface)
        -- receive request
        RegisterNetEvent(name..":tunnel_req")
        AddEventHandler(name..":tunnel_req",function(member,args,identifier,rid)
            local f = interface[member]

            local delayed = false

            local rets = {}
            if type(f) == "function" then
            -- bind the global function to delay the return values using the returned function with args
            TUNNEL_DELAYED = function()
                delayed = true
                return function(rets)
                rets = rets or {}
                if rid >= 0 then
                    TriggerServerEvent(name..":"..identifier..":tunnel_res",rid,rets)
                end
                end
            end

            rets = {f(table.unpack(args))} -- call function 
            -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
            end

            -- send response (event if the function doesn't exist)
            if not delayed and rid >= 0 then
            TriggerServerEvent(name..":"..identifier..":tunnel_res",rid,rets)
            end
        end)
        end

        -- get a tunnel interface to send requests 
        -- name: interface name
        -- identifier: unique string to identify this tunnel interface access (the name of the current resource should be fine)
        function Tunnel.getInterface(name,identifier)
        local ids = Tools.newIDGenerator()
        local callbacks = {}

        -- build interface
        local r = setmetatable({},{ __index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })

        -- receive response
        RegisterNetEvent(name..":"..identifier..":tunnel_res")
        AddEventHandler(name..":"..identifier..":tunnel_res",function(rid,args)
            local callback = callbacks[rid]
            if callback ~= nil then
            -- free request id
            ids:free(rid)
            callbacks[rid] = nil

            -- call
            callback(table.unpack(args))
            end
        end)

        return r
        end
        ---- END TUNNEL CLIENT SIDE VERSION

        vRPserver = Tunnel.getInterface("vRP", "vRP")
    end
    vRP = Proxy.getInterface("vRP")

    -- vRP 2
    -- Proxy = module("vrp", "lib/Proxy")
    -- vRP = Proxy.getInterface("vRP")
    -- vRP.loadScript(GetCurrentResourceName(), "config.lua")

else
    Config.Framework = FRAMEWORK_STANDALONE
end