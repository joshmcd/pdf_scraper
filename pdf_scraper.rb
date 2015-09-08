#!/usr/bin/ruby

require 'mechanize'
require 'pdf-reader'
require 'uri'

puts 'What Instructor should we use? (Name is case-sensitive) '

inst = gets.chomp.to_s
path = 	'C:/Users/jmcdon39/Desktop/'
f = path + inst + ".pdf"
g = path + "test.txt"
pdf = PDF::Reader.new(f)
file = File.open( g, "w+" )
pdf.pages.each do |i|
  file << i.text
end
file.close

=begin - there's a better way to do this: text = File.read(path)
list = File.open( g, "w+" )
text = list.readlines
=end

text = File.read(g)
text.strip.gsub(/\s+/, " ").gsub(/"/, "").gsub(/,/, "").scan(/https?:\/\/[\S]+/) #gets the links, but they still break at newlines


#here we have to extract the articles and URLs from the pdf. 
#again there's the problem of multiple kinds of quote character: “””" etc.
# there's the unicode bullet: \u2022
# the right double-quote: \u201D
# and left double-quote: \u201C
#URL regex: /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
#clean everything up: .strip.gsub(/\s+/, " ")
# so article.to_s.strip.gsub(/\s+/, " ").scan(/https?:\/\/[\S]+/) works, once you have the text. The regex needs to stop at a comma or " though
#.to_s.strip.gsub(/\s+/, " ").gsub(/"/, "").gsub(/,/, "").scan(/https?:\/\/[\S]+/) will also remove the trailing commas.

agent = Mechanize.new
	
  agent.user_agent_alias = 'Mac Safari'
=begin example for downloading a file with mechanize:
  agent.pluggable_parser.default = Mechanize::Download
  agent.get('http://example.com/foo').save('a_file_name')
=end
	page = agent.get("http://scholar.google.com")
	form = agent.page.forms.first
	form.field_with(:name => "q").value = article
  newbutton = form.button_with(:name => "btnG")
  page = agent.submit(form, newbutton)
  dbpage = page.links_with(:text => /PDF/)[0].click
  source = dbpage.uri
  
 #this is where the download pdf logic should go. 
  
  agent.pluggable_parser.default = Mechanize::Download
  agent.get('http://example.com/foo').save('a_file_name')
  
  
  if source.to_s.include?("jstor")
    
  
  elsif source.to_s.include?("proquest")
  #etcetc.
  end