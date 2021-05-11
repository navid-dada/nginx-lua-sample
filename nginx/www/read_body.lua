local json = require("cjson")
ngx.req.read_body();
local body = json.decode(ngx.req.get_body_data())

local event={
    BidRequestId=body.id,
    maximumTimeOut=body.tmax,
    auctionType= body.type,
    rtbVersion= 2.5,
    userInfo={
        externalId = body.user.id
    },
    deviceInfo={
        type= body.device.devicetype,
        language=body.device.language,
        os= body.device.os,
        osVersion= body.device.osv,
        model= body.device.model,
        make= body.device.make,
        ip= body.device.ip
    },
    appInfo = {},
    siteInfo = {},
    items = {},
    publisherInfo = {}
}

if body.device.ext ~= nil then
    event.deviceInfo.browserUserAgent= body.device.ext.browser
end
if body.device.geo ~= nil then
    event.deviceInfo.geo = {}
    event.deviceInfo.geo.country = body.device.geo.country
end 


for k, v in pairs(body.imp) do
    event.items[k]={}
    event.items[k].minimumBidFloor = v.bidfloor
    event.items[k].bidFloorCurrency = vbidfloorcur
    event.items[k].Id = v.id
    event.items[k].type = v.secure
    event.items[k].displayPlacementInfo = {
        mimeTypes = v.banner.mimes,
        topFrame = v.banner.topframe,
        width = v.banner.w,
        height = v.banner.h,
        positionOnScreen = v.banner.pos,
    }
    
end


if body.app ~= nil then 
    event.publisherType = "app" 
    event.appInfo ={
        externalId = body.app.id,
        name = body.app.name,
        bundle = body.app.bundle,
        domain = body.app.domain,
        categories = body.app.cat,
        sectionCategories = nil
    }
    --event["appInfo"]["version"] = 
    event.siteInfo = nil
    event.publisherInfo.externalId = body.app.publisher.id
else
    event.publisherType = "site"
    event.siteInfo ={
        externalId = body.site.id,
        name = body.site.name,
        domain = body.site.domain,
        pageUrl = body.site.page,
        categories = nil,
        sectionCategories = body.site.sectioncat
    }
    event.appInfo = nil
    event.publisherInfo.externalId = body.site.publisher.id
end

kafka.sendmessage("_DspBidRequestedIntegrationEvent", json.encode(event))
--ngx.say(json.encode(event));
