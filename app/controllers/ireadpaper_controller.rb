require 'net/http'
require 'uri'

class IreadpaperController < ApplicationController
  
  def index
    process_paper(params[:paper]) if params[:paper].present?
  end


  def process_paper(paper_url)

  	paper_host_name = get_url_host_name(paper_url)

  	page_content = get_page_content(paper_url)

	@processed_paper = page_content.html_safe
  end

  def get_url_host_name(url)
  	myUri = URI.parse(url)
	return myUri.host
  end


  def get_page_content(url)
  	url = URI.parse(url)
	req = Net::HTTP::Get.new(url.path)
	res = Net::HTTP.start(url.host, url.port) {|http|
  		http.request(req)
	}
	return res.body
  end

end
