module LocationByIp
  def LocationByIp.acquire(request)

      language = "en"
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

      # ip = '212.90.62.43'

      # jsn = '{"location":{"latitude":50.4333,"longitude":30.5167,"time_zone":"Europe/Kiev"},"subdivisions":[{"iso_code":"30","names":{"ru":"Киев","en":"Kyiv City"},"geoname_id":703447}],"maxmind":{"queries_remaining":1000},"traits":{"autonomous_system_number":48239,"organization":"End user ip pool","isp":"Scientific-Production Enterprise Information Techn","ip_address":"212.90.62.43","autonomous_system_organization":"Scientific-Production Enterprise Information Technologies Ltd","domain":"it-tv.org"},"registered_country":{"iso_code":"UA","geoname_id":690791,"names":{"fr":"Ukraine","zh-CN":"乌克兰","en":"Ukraine","es":"Ucrania","ru":"Украина","ja":"ウクライナ共和国","pt-BR":"Ucrânia","de":"Ukraine"}},"country":{"iso_code":"UA","geoname_id":690791,"names":{"de":"Ukraine","pt-BR":"Ucrânia","ru":"Украина","es":"Ucrania","ja":"ウクライナ共和国","zh-CN":"乌克兰","fr":"Ukraine","en":"Ukraine"}},"continent":{"code":"EU","geoname_id":6255148,"names":{"en":"Europe","fr":"Europe","zh-CN":"欧洲","pt-BR":"Europa","de":"Europa","ja":"ヨーロッパ","es":"Europa","ru":"Европа"}},"city":{"names":{"de":"Kiew","pt-BR":"Kiev","ja":"キエフ","en":"Kiev","ru":"Киев","es":"Kiev","fr":"Kiev"},"geoname_id":703448}}'

      # data = JSON.parse(jsn)

      #----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- #

      Rails.logger.debug "Production mode."
      data = Geoip2.city(ip)

      result = {}

      if data["country"] != nil
        if data["country"]["names"] != nil
          if data["country"]["names"][language] != nil
            result["country"] = data["country"]["names"][language]
          end
          if data["country"]["names"]["en"] != nil
            result["country_en"] = data["country"]["names"]["en"]
          end
        end
      end

      if data["city"] != nil
        if data["city"]["names"] != nil
          if data["city"]["names"][language] != nil
            result["city"] = data["city"]["names"][language]
          end
          if data["city"]["names"]["en"] != nil
            result["city_en"] = data["city"]["names"]["en"]
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
        :data => result }

    end


  end
end

