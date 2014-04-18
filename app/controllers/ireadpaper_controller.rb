require 'net/http'
require 'uri'
require 'open-uri'
require 'action_view'
require 'json'

class IreadpaperController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  @@google_apikey = "AIzaSyCV6gBqA0T_xkDXd1UVEeWSImxX9ogtsCs"

  def index
    process_paper(params[:paper]) if params[:paper].present?
  end


  def process_paper(url)

  	#paper_host_name = get_url_host_name(url)

    # remove js and css tag and get main content 
    page = Nokogiri::HTML(open(url))
    page_content = page.css('body')
    page_content.css('script').remove  
    page_content.css('link').remove 
    page_content.css('style').remove 

    # clear html tag.
    page_content = strip_tags(page_content) 

    # text to words
    words = text_to_words(page.content)
    new_page_content = mask_tranlate_word(page.to_html,words)
	  @processed_paper = new_page_content.html_safe
  end

  def get_clear_page(url)

  end

  def mask_tranlate_word(page, words)
    words.each do |word|
      tw_word = en_to_tw_tranlate(word)
      page.sub! word, "#{word}{#{tw_word}}"
    end
    page
  end

  def en_to_tw_tranlate(en_word)
    word = local_translare("en", "zh_tw", en_word.downcase)
    if word == nil
      word = google_translate("en", "zh-TW", en_word)
      write_translate_to_local("en", "zhtw", en_word.downcase, word)
    end
    word
  end

  def write_translate_to_local(source, target, source_word, target_word)
    Dictionary.create( :en => source_word, :zhtw => target_word)
  end

  def local_translare(source, target, q)
    dictionary = Dictionary.where( "en = ?", q).first
    dictionary.zhtw if dictionary
  end

  def google_translate(source, target, q)
    url = "https://www.googleapis.com/language/translate/v2?key=#{@@google_apikey}&q=#{q}&source=#{source}&target=#{target}"
    result = get_page_content(url)
    Rails.logger.info result
    result_json = JSON.parse result
    word = result_json["data"]["translations"][0]["translatedText"] if result_json.present?
  end


  def text_to_words(text)
    words = text.split(/\W+/)
    words = get_unique_words(words)
  end
  
  def get_unique_words(words)
    unique_words = []
    words.each do |word|
      unique_words << word if /[a-zA-Z]/.match(word) and !unique_words.include? word
    end  
    unique_words
  end

  def get_url_host_name(url)
    myUri = URI.parse(url)
    myUri.host
  end

  def get_page_content(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.body
  end


end
