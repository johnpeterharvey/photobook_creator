require 'prawn'
require 'json'
require 'date'
require 'pathname'

page_data = {}
feed_file = File.open 'export/feed.json'
data = JSON.load feed_file
data['items'].each do |item|
  item_date = DateTime.parse(item['date_published']).strftime('%Y-%m-%d')
  item_description = /<p>([^<]+)/.match(item['content_html'])[1].gsub("\n", ', ')
  image_source = /src=\"([^\"]+)/.match(item['content_html'])[1]
  page_data[item_date] = {:description => item_description, :source => image_source}
end
page_data = page_data.sort_by { |date, values| date }

Prawn::Document.generate("out.pdf", page_size: [693, 594], :margin => [0,0,0,0]) do
  page_data.each do |date, values|
    start_new_page

    # Formatting
    fill_color '000000'
    fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
    font('/System/Library/Fonts/HelveticaNeue.ttc', size: 11, style: 'Light')
    fill_color 'FFFFFF'

    # Contents
    image_file = Pathname.new("export/#{values[:source]}")
    if image_file.exist?
      image image_file.realpath, :at => [0, bounds.top], :position => :center, :vposition => :center, :fit => [693, 540]
    else
      puts "Problem image #{date} - #{image_file}"
    end
    text_box "#{date}: #{values[:description]}", :at => [0, 40], :width => bounds.right, align: :center
  end
end
