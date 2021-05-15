ngx.req.read_body()
local body = ngx.req.get_body_data()
kafka.send("DspBidRequestedIntegrationEvent", body)


local red = redis:new()
local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local res, err = red:auth(REDIS_AUTH_KEY)
if not res then
    ngx.log(ngx.ERR, err)
	return
end	

local retry = 0;
local res, err = red:get(body.id)
while retry < 20 and res == ngx.null do
    ngx.say("try to get response")
    res, err = red:get(body.id)
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