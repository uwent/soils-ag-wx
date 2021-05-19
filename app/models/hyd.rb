class Hyd < ApplicationRecord
  include Assessable

  OUTPUT_BASE_DIR = File.join(Dir.home, "hyd")

  def self.load_file(date = Date.current)
    dirname = output_directory(date.year)
    fname = File.join(dirname, filename(date))
    File.write(fname, get_data)
    fname
  end

  def self.output_directory(year)
    Dir.mkdir(OUTPUT_BASE_DIR) unless File.exists?(OUTPUT_BASE_DIR)
    dir = File.join(OUTPUT_BASE_DIR, year.to_s)
    Dir.mkdir(dir) unless File.exists?(dir)
    dir
  end

  def self.filename(date)
    "opu#{date.year}#{'%03d' % date.yday}"
  end

  def self.get_data(version = 1)
    server = 'forecast.weather.gov'
    url = sprintf('/product.php?site=NWS&issuedby=MKX&product=HYD&format=TXT&version=%0d&glossary=0',version.to_i)

    uri = URI("https://#{server}#{url}")
    res = Net::HTTP.get(uri)

    if res
      preface, body = res.split(/\<pre .*>/)
      if body
        body, footer = body.split '$$'
        return body
      else
        return "No body found HYD retrieval"
      end
    else
      return "No result from '#{url}'"
    end
  end

end
