require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'yaml'

drugs = []
i = 0
(i*5000 + 1).upto((i+1)*5000) do |i|
	s = open("http://www.webapteka.ru/drugbase/name#{i}.html")
	doc = Nokogiri::HTML(s, nil, "koi8-r")
	table = doc
		.xpath("//div[@style='_width:100%; padding:5px; clear:left']")
		.first
	next unless table
	table.css("span").first.remove
	values = []
	names = []
	drug = {}
	drug["link"] = "http://www.webapteka.ru/drugbase/name#{i}.html"
	table.xpath(".//div[@style='margin-left:20px']").each do |el|
		values << el.text
		el.remove
	end
	table.css("b").each do |a|
		names << a.text
	end

	names.each_with_index do |name, index|
		drug[name.gsub(/:$/, "")] = values[index]
	end
	drugs << drug
end
File.open("drugs#{i}.yml", "w") do |file|
  file.write drugs.to_yaml
end