#!/usr/bin/ruby


# So the easiest way to deal with encoding issues seems to be just cutting/pasting all the text from pdf
#this requires that you ctrl-f to replace weird quotes, but ends up being faster than messing with it in Ruby, so far
#require 'pdf-reader' might try docsplit instead
#require 'docsplit'
#require 'uri'
require 'mechanize'
require 'watir-webdriver'
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
        when /404/ then log.puts '404!'
        when /500/ then log.puts '500!'
        else log.puts 'IDK!'
    end
   end
end

#the above is bad practice according to http://daniel.fone.net.nz/blog/2013/05/28/why-you-should-never-rescue-exception-in-ruby/

puts 'What Instructor should we use? (Name is case-sensitive) '
inst = gets.chomp.to_s

puts 'What Operating System are you on ? "w" for windows, "u" for osx/linux'
os = gets.chomp.to_s
case os
  when 'w' 
    path = 'C:/Users/jmcdon39/Desktop/' + inst + '/'#according to SO you can use %HOMEPATH% as an equivalent to ~, %HOMEPATH%/Desktop/ ? nope.
  when 'u' 
    path = '~/Desktop/' + inst + '/'
  else 
  puts 'Answer must be w or u '
end

unless
    File.exist?(path)
    Dir.mkdir(path)
end
log = path + 'log.txt'
log = File.open(log, 'w+')

profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.dir'] = path
profile['browser.link.open_newwindow'] = 3

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

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
# downloading a file with mechanize:
  agent.pluggable_parser.default = Mechanize::Download

  urls.each do |url|
   if 
    url.to_s.include?('pdf')
    page = geturl(agent, url)
    #page = agent.get(url)
    unless page == nil
    page.save( path + filename_sanitize(page.title) + ".pdf") 
    log.puts page.title + 'success'
    end
    else
    page = geturl(agent, url)
    unless page == nil
    page.save( path + filename_sanitize(page.title) + ".html")
    log.puts page.title + 'success'
    end
   end
  end #url loop - works to here!

browser = Watir::Browser.new :firefox, :profile => profile
articles.each do |article|
	page = agent.get("http://scholar.google.com")
	form = agent.page.forms.first
	form.field_with(:name => "q").value = article
  newbutton = form.button_with(:name => "btnG")
  page = agent.submit(form, newbutton)
  r = page.links_with(:text => /PDF/) #links[39] may be a better bet
  #maybe it should be a case statement
  unless r == nil
    dbpage = page.links_with(:text => /PDF/)[0].click 
  end
  
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
      log.puts dbpage.to_s + 'failed for some reason, probably because it\'s not proquest or jstor' 
      #break
  #etcetc.
    end # if loop
  end #articles loop

