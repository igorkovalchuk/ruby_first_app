require_dependency 'location_by_ip'
class Geoip2ServiceController < ApplicationController
  def location
    result = LocationByIp.acquire(request, params[:language])
    render :json => result
  end
end

