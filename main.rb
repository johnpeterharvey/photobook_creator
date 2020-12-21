require 'prawn'
require 'json'
require 'date'

feed_file = File.open 'export/feed.json'
data = JSON.load feed_file
data['items'].each do |item|
  item_date = DateTime.parse(item['date_published']).strftime('%Y-%m-%d')
  item_description = /<p>([^<]+)/.match(item['content_html'])[1].gsub("\n", ', ')
  image_source = /src=\"([^\"]+)/.match(item['content_html'])[1]
  p "#{item_date}: #{item_description}"
end

Prawn::Document.generate("out.pdf", page_size: [693, 594], :margin => [0,0,0,0]) do
  fill_color '000000'
  fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top

  image = "./example2.jpg"
  image image, :at => [0, bounds.top], :position => :center, :vposition => :center, :fit => [693, 540]

  font('/System/Library/Fonts/HelveticaNeue.ttc', size: 11, style: 'Light')
  fill_color 'FFFFFF'
  text_box '2020-03-03: Test Image', :at => [0, 40], :width => bounds.right, align: :center
end
