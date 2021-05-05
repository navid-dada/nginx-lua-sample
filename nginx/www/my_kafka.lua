local producer = require "resty.kafka.producer"
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

