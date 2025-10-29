local resty_string = require "resty.string"
local resty_hmac = require "resty.hmac"

ngx.req.read_body()
local body = ngx.req.get_body_data() or ""

local signature = ngx.req.get_headers()["X-Hub-Signature-256"]
if not signature then
  ngx.log(ngx.ERR, "missing X-Hub-Signature-256 header")
  return ngx.exit(ngx.HTTP_FORBIDDEN)
end

local path = ngx.var.uri
local secret = nil
if path == "/sonarqube" then
  secret = os.getenv("SONAR_SECRET")
elseif path == "/artifactory" then
  secret = os.getenv("ARTIFACTORY_SECRET")
elseif ngx.re.find(path, "^/jenkins") then
  secret = os.getenv("JENKINS_SECRET")
else
  ngx.log(ngx.ERR, "unknown path for secret selection: " .. tostring(path))
  return ngx.exit(ngx.HTTP_FORBIDDEN)
end

if not secret then
  ngx.log(ngx.ERR, "secret not set for path: " .. tostring(path))
  return ngx.exit(ngx.HTTP_FORBIDDEN)
end

local hmac = resty_hmac:new(secret, resty_hmac.ALGOS.SHA256)
local digest = hmac:final(body)
local hex = resty_string.to_hex(digest)
local expected = "sha256=" .. hex

if expected ~= signature then
  ngx.log(ngx.ERR, "invalid signature; expected=" .. expected .. " got=" .. tostring(signature))
  return ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- passed
return
