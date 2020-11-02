class Hyd < ApplicationRecord
  include Assessable

  OUTPUT_BASE_DIR = "/home/deploy/hyd"

  def self.load_file(date=Date.current)
    fname = filename(date)
    File.write("#{output_directory(date.year)}/#{fname}", get_data)
  end

  def self.filename(date)
    "opu#{date.year}#{'%03d' % date.yday}"
  end

  def self.get_data(version=1)
    server = 'forecast.weather.gov'
    url = sprintf('/product.php?site=NWS&issuedby=MKX&product=HYD&format=TXT&version=%0d&glossary=0',version.to_i)

    uri = URI("https://#{server}#{url}")
    res = Net::HTTP.get(uri)

    if res
      preface,body = res.split(/\<pre .*>/)
      if body
        body,footer = body.split '$$'
        return body
      else
        return "No body found HYD retrieval"
      end
    else
      return "No result from '#{url}'"
    end
  end

  def self.output_directory(year)
    dir = "#{OUTPUT_BASE_DIR}/#{year}"
    Dir.mkdir(dir) unless File.exists?(dir)

    return dir
  end
end
