module LocationByIp
  def LocationByIp.acquire(request, language)

    # language = "en"

    if language.nil? || language.empty?
      language = "en"
    end

    if language == "pt"
      language = "pt-BR"
    end

    Geoip2.configure do |conf|
      # Mandatory
      conf.license_key =  ENV["MM_KEY"]
      conf.user_id =  ENV["MM_USER_ID"]

      # Optional
      conf.host = 'geoip.maxmind.com' # Or any host that you would like to work with
      conf.base_path = '/geoip/v2.1' # Or any other version of this API
      # conf.parallel_requests = 5 # Or any other amount of parallel requests that you would like to use
    end

    a1 = request.env["HTTP_X_FORWARDED_FOR"]
    a2 = request.remote_ip

    if a1 == nil
      a1 = ""
    end

    if a2 == nil
      a2 = ""
    end

    Rails.logger.debug "IP, HTTP_X_FORWARDED_FOR = " + a1
    Rails.logger.debug "IP, request.remote_ip = " + a2

    ip = a1
    if ip.empty?
      ip = a2
    end

    if ip.empty?
      return { :success => false }
    end

    unless ip.empty?

      #----- Testing --- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- #

      # Rails.logger.debug "Testing mode."

      # ip = '192.30.252.128'

      # jsn = '{"country":{"names":{"en":"United States","zh-CN":"美国","de":"USA","es":"Estados Unidos","pt-BR":"Estados Unidos","ja":"アメリカ合衆国","fr":"États-Unis","ru":"США"},"iso_code":"US","geoname_id":6252001},"location":{"metro_code":807,"time_zone":"America/Los_Angeles","longitude":-122.3933,"latitude":37.7697},"city":{"geoname_id":5391959,"names":{"ru":"Сан-Франциско","fr":"San Francisco","ja":"サンフランシスコ","pt-BR":"São Francisco","es":"San Francisco","de":"San Francisco","zh-CN":"旧金山","en":"San Francisco"}},"maxmind":{"queries_remaining":983},"postal":{"code":"94107"},"registered_country":{"geoname_id":6252001,"names":{"en":"United States","zh-CN":"美国","es":"Estados Unidos","de":"USA","pt-BR":"Estados Unidos","ja":"アメリカ合衆国","ru":"США","fr":"États-Unis"},"iso_code":"US"},"continent":{"geoname_id":6255149,"names":{"en":"North America","de":"Nordamerika","es":"Norteamérica","zh-CN":"北美洲","pt-BR":"América do Norte","ru":"Северная Америка","fr":"Amérique du Nord","ja":"北アメリカ"},"code":"NA"},"traits":{"autonomous_system_number":36459,"isp":"GitHub","organization":"GitHub","ip_address":"192.30.252.128","autonomous_system_organization":"GitHub, Inc."},"subdivisions":[{"geoname_id":5332921,"names":{"zh-CN":"加利福尼亚州","de":"Kalifornien","es":"California","en":"California","ja":"カリフォルニア州","ru":"Калифорния","fr":"Californie","pt-BR":"Califórnia"},"iso_code":"CA"}]}'

      # data = JSON.parse(jsn)

      #----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- #

      # Rails.logger.debug "Production mode."

      faraday_options = {:request => {:timeout => 5, :open_timeout => 5}}

      data = {}
      begin
        data = Geoip2.city(ip, faraday_options)
      rescue => e
        Rails.logger.error "Exception: " + e.inspect + " " + e.message
        return { :success => false, :exc_class => e.inspect, :exc_message => e.message }
      end

      result = {}

      if data["continent"] != nil
        if data["continent"]["geoname_id"] != nil
          result["continent_id"] = data["continent"]["geoname_id"]
        end
        if data["continent"]["names"] != nil
          if data["continent"]["names"]["en"] != nil
            result["continent_en"] = data["continent"]["names"]["en"]
          end
        end
      end

      if data["country"] != nil
        if data["country"]["geoname_id"] != nil
          result["country_id"] = data["country"]["geoname_id"]
        end
        if data["country"]["names"] != nil
          if data["country"]["names"]["en"] != nil
            result["country_en"] = data["country"]["names"]["en"]
            result["country"] = data["country"]["names"]["en"]
          end
          if data["country"]["names"][language] != nil
            result["country"] = data["country"]["names"][language]
          end
        end
      end

      if data["city"] != nil
        if data["city"]["geoname_id"] != nil
          result["city_id"] = data["city"]["geoname_id"]
        end
        if data["city"]["names"] != nil
          if data["city"]["names"]["en"] != nil
            result["city_en"] = data["city"]["names"]["en"]
            result["city"] = data["city"]["names"]["en"]
          end
          if data["city"]["names"][language] != nil
            result["city"] = data["city"]["names"][language]
          end
        end
      end

      if data["maxmind"] != nil
        if data["maxmind"]["queries_remaining"] != nil
          result["queries"] = data["maxmind"]["queries_remaining"]
        end
      end

      return { :success => true, 
        :user_ip => ip,
        :language => language,
        :data => result }

    end


  end
end

