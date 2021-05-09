local producer = require "resty.kafka.producer"
local redis = require "resty.redis"

local broker_list = {
    {
        host= "93.115.151.144",
        port= 9092
    }
}
local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send("_lua_topic", "my_key", ngx.var.reqid)
if not ok then
  ngx.say("send err:", err)
  return
end

ngx.say("message sent!!!"..ngx.var.reqid)

local red = redis:new()
local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

--local res, err = red:auth("abcd")
--if not res then
--    ngx.log(ngx.ERR, err)
--    return
--end	

local retry = 0;
local res, err = red:get(ngx.var.reqid)
while retry < 20 and res == ngx.null do
    ngx.say("try to get response")
    res, err = red:get(ngx.var.reqid)
    if not res then
        ngx.say("failed to get req_id: ", err)
        return
    end
    os.execute(package.config:sub(1,1) == "/" and "sleep 0.2" or "timeout 0.2")
    retry = retry + 1
end
if res == ngx.null then 
    ngx.say("no response")
    return
end
ngx.say("response: ", res)