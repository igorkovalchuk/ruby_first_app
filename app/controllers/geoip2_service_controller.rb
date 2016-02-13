# require 'trig'
require 'location_by_ip'
class Geoip2ServiceController < ApplicationController
  def location
    result = LocationByIp.acquire(request)
    render :json => result
  end
end

