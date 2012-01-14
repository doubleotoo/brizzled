module Jekyll

  module DateTimeUtil

    def rfc3339_datetime(dt)
      dt.strftime('%Y-%m-%dT%H:%M:%S') + 'Z'
    end

    def rfc822_datetime(dt)
      dt.strftime('%a, %d %b %Y %T %z')
    end
  end
end