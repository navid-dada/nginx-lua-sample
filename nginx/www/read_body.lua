local json = require("resty.JSON")
ngx.req.read_body();
local body = json:decode(ngx.req.get_body_data())
body["age"] = 33;

ngx.say(json:encode(body));