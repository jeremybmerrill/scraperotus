#Written especially for downloading supreme court opinions as PDFs; parse the index pages, grab urls, then grab the pdfs that live at that url

require 'nokogiri'
require 'fileutils'
require 'net/http'
require 'uri'

high_level_indices = ["http://www.supremecourt.gov/opinions/05pdf/", "http://www.supremecourt.gov/opinions/08pdf/", "http://www.supremecourt.gov/opinions/07pdf/", "http://www.supremecourt.gov/opinions/06pdf/"]

def restoreLinksFromFile(filename)
  return json.loads(open(filename, "r").read())
end

def grabPage(url)
  year = url.split("/")[-1]
  if File.exists?("indices/" + year + ".html")
    puts "using cached index page"
    html = open("indices/" + year + ".html", "r").read
  else
    uri = URI.parse(url)
    puts "no cache for " + url + ", dling"
    html = Net::HTTP.get_response(uri)
    open("indices/" + year + ".html", "w").write(html.body)
  end
  return html
end

def getPDF(name, url)
  escapedName = name.gsub("/", "")
  year = url.split("/")[-2]
  if File.exists?("pdfs/" + year + "/" + escapedName + ".pdf")
    puts escapedName + " already exists!"
  else
    FileUtils.mkdir("pdfs/" + year + "/") unless File.exists?("pdfs/" + year + "/")

    pdf = open("pdfs/" + year + "/" + escapedName + ".pdf", "wb")
    uri = URI.parse(url)
    begin
      response = Net::HTTP.get(uri)
      result = pdf.write(response)
      puts escapedName + " written successfully"
    rescue IOError
      puts escapedName + " failed"
    end
  end
end

def getCasesFromIndex(html, url)
  noko = Nokogiri::HTML(html, encoding="utf-8")
  secondCenter = noko.xpath("//center//center//a")
  puts secondCenter.inspect
  links = []
  secondCenter.each do |link|
    links << [link.text, url + link['href']]
  end
  return links
end


#main
high_level_indices.each do |index|
  links = getCasesFromIndex(grabPage(index), index)
  links.each do |link|
    puts link.inspect
    getPDF(link[0], link[1])
  end
end