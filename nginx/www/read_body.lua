local json = require("cjson")
ngx.req.read_body();
local body = json.decode(ngx.req.get_body_data())

local event = {}
event["appInfo"] ={}
event["siteInfo"] ={}
event["items"] = {}
event["userInfo"] ={}
event["publisherInfo"]={}

event["bidRequestId"] = body["id"]
event["maximumTimeOut"] = body["tmax"]
event["auctionType"] = body["type"]
event["rtbVersion"] = 2.5
event["userInfo"]["externalId"]= body["user"]["id"]

for k, v in pairs(body["imp"]) do
    event["items"][k] = {}
    event["items"][k]["minimumBidFloor"] = v["bidfloor"]
    event["items"][k]["bidFloorCurrency"] = v["bidfloorcur"]
    event["items"][k]["Id"] = v["id"]
    event["items"][k]["type"] = v["secure"]
    event["items"][k]["displayPlacementInfo"] = {}
    event["items"][k]["displayPlacementInfo"]["mimeTypes"] = v["banner"]["mimes"]
    event["items"][k]["displayPlacementInfo"]["topFrame"] = v["banner"]["topframe"]
    event["items"][k]["displayPlacementInfo"]["width"] = v["banner"]["w"]
    event["items"][k]["displayPlacementInfo"]["height"] = v["banner"]["h"]
    event["items"][k]["displayPlacementInfo"]["positionOnScreen"] = v["banner"]["pos"]
end


if body["app"] ~= nil then 
    event["publisherType"] = "app" 
    event["appInfo"]["externalId"] = body["app"]["id"]
    event["appInfo"]["name"] = body["app"]["name"]
    event["appInfo"]["bundle"] = body["app"]["bundle"]
    event["appInfo"]["domain"] = body["app"]["domain"]
    event["appInfo"]["categories"] = body["app"]["cat"]
    event["appInfo"]["sectionCategories"] = nil
    --event["appInfo"]["version"] = 
    event["siteInfo"] = nil
    event["publisherInfo"]["externalId"] = body["app"]["publisher"]["id"]
else
    event["publisherType"] = "site"
    event["siteInfo"]["externalId"] = body["site"]["id"]
    event["siteInfo"]["name"] = body["site"]["name"]
    event["siteInfo"]["domain"] = body["site"]["domain"]
    event["siteInfo"]["pageUrl"] = body["site"]["page"]
    event["siteInfo"]["categories"] = nil
    event["siteInfo"]["sectionCategories"] = body["site"]["sectioncat"]
    event["appInfo"] = nil
    event["publisherInfo"]["externalId"] = body["site"]["publisher"]["id"]

end

kafka.sendmessage("_DspBidRequestedIntegrationEvent", json.encode(event))
ngx.say(json.encode(event));
