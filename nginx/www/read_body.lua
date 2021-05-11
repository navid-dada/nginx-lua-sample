--local json = require("cjson")
ngx.req.read_body();
local body = ngx.req.get_body_data()
kafka.sendmessage("DspBidRequestedIntegrationEvent", json.encode(event))
--ngx.say(json.encode(event));
