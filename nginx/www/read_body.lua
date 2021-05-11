--local json = require("cjson")
ngx.req.read_body();
local body = ngx.req.get_body_data()
kafka.sendmessage("DspBidRequestedIntegrationEvent", body)
--ngx.say(json.encode(event));
