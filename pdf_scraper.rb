#!/usr/bin/ruby

#require 'pdf-reader' might try docsplit instead
#require 'docsplit'
#require 'uri'
require 'mechanize'
require 'watir-webdriver'
puts 'What Instructor should we use? (Name is case-sensitive) '
inst = gets.chomp.to_s
path = 'C:/Users/jmcdon39/Desktop/'
profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.dir'] = path
profile['browser.link.open_newwindow'] = 3

def extract_quotes(text_string)
  text_string.gsub(/[^[:print:]]/,'').gsub(/\s\s+/, ' ').scan(/"(.*?)"/)
end

def filename_sanitize(name)
  name.to_s.tr('&%*@()!{}|?', '')
end

def geturl(a, b)
  begin
    page = a.get(b)
    rescue Exception => e
    case e.message
        when /404/ then puts '404!'
        when /500/ then puts '500!'
        else puts 'IDK!'
    end
end
    
# So the easiest way to deal with encoding issues seems to be just cutting/pasting all the text from pdf
#this requires that you ctrl-f to replace weird quotes, but ends up being faster than messing with it in Ruby, so far
#f = path + inst + ".pdf"
g = path + inst + ".txt"
text = File.read(g)
articles = []
urls = []
extract_quotes(text).each { |i| articles << i } #reads it all into an array called articles
text.scan(/https?:\/\/[\S]+/).each { |i| urls << i }
#text.scan(/.+?(?=http)/) will get you the entire line up to the url; 
#pdf = PDF::Reader.new(f)
#file = File.open( g, "r+" )
#pdf.pages.each do |i|
#  file << i.text
#end
#file.close

=begin - there's a better way: text = File.read(path)
list = File.open( g, "w+" )
text = list.readlines
text = File.read(g)
text.gsub($fancyDoubleQuotes, '"')
text.strip.gsub(/\s+/, "").gsub(/"/, "").gsub(/,/, "").scan(/https?:\/\/[\S]+/) #gets the links, but they still break at newlines
#here we have to extract the articles and URLs from the pdf. 
#again there's the problem of multiple kinds of quote character: “””" etc.
# there's the unicode bullet: \u2022
# the right double-quote: \u201D
#so you can just do .gsub(/\u201D/, '"').gsub(/\u201C/, '"')
# and left double-quote: \u201C
#URL regex: /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/
#clean everything up: .strip.gsub(/\s+/, " ")
# so article.to_s.strip.gsub(/\s+/, " ").scan(/https?:\/\/[\S]+/) works, once you have the text. The regex needs to stop at a comma or " though
#.to_s.strip.gsub(/\s+/, " ").gsub(/"/, "").gsub(/,/, "").scan(/https?:\/\/[\S]+/) will also remove the trailing commas.
#.gsub!(/\n+/, "") gets rid of all newlines
.gsub(/\s\s+/, ' ') turns all spaces to single space.
.gsub(/[^[:print:]]/,'').gsub(/\s\s+/, ' ').scan(/"(.*?)"/) gets rid of all non-printing characters and pulls everything between quotes
=end

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
# downloading a file with mechanize:
  agent.pluggable_parser.default = Mechanize::Download

  urls.each do |url|
   if 
    url.to_s.include?('pdf')
    geturl(agent, url)
    #page = agent.get(url)
    page.save( path + page.title.to_s.tr('&%*@()!{}|?', '') + ".pdf") #needs to be replaced with a method
    else
    geturl(agent, url)
    page.save( path + page.title.to_s.tr('&%*@()!{}|?', '') + ".html")
   end
  end #url loop
=begin
browser = Watir::Browser.new :firefox, :profile => profile
articles.each do |article|
	page = agent.get("http://scholar.google.com")
	form = agent.page.forms.first
	form.field_with(:name => "q").value = article
  newbutton = form.button_with(:name => "btnG")
  page = agent.submit(form, newbutton)
  dbpage = page.links_with(:text => /PDF/)[0].click #this is links[39] 
  source = dbpage.uri.to_s
    if source.to_s.include?("jstor")
      #this is where we're gonna have to use watir sadly, since all of them have js popups
      browser.goto(source)
      title = browser.div(:class => "title").text.tr('&%*@()!{}|?', '')
      browser.link(:text => "Download PDF").click
      browser.link(:text => "I Accept").click
      browser.windows[1].use
      browser.button(:id => "download").click
      oldname = path + browser.title.to_s + ".pdf"
      newname = path + title + ".pdf"
      File.rename(oldname, newname)
      browser.windows[1].close
      
    elsif source.to_s.include?("proquest")
      title = filename_sanitize(browser.h1s[0].text)
      browser.link(:id => "downloadPDFLink").click
      browser.windows[1].use
      oldname = path + "out.pdf" #proquest seems to name them all this way
      newname = path + title + ".pdf"
      browser.windows[1].close
    else 
      break
  #etcetc.
    end # if loop
  end #articles loop
=end