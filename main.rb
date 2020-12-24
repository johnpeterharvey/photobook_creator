require 'prawn'
require 'prawn/emoji'
require 'json'
require 'date'

current_year = 2020
page_width = 693
page_height = 594

page_data = {}
feed_file = File.open 'export/feed.json'
data = JSON.load feed_file
data['items'].each do |item|
  item_date = DateTime.parse(item['date_published']).strftime('%Y-%m-%d')
  item_description = /<p>([^<]+)/.match(item['content_html'])[1].gsub("\n", ', ')
  image_source = /src=\"([^\"]+)/.match(item['content_html'])[1]
  page_data[item_date] = {:description => item_description, :source => image_source}
end
dates = page_data.keys.sort.select {|date| /^#{current_year}.*/.match(date)}.slice_before(/.*01$/).to_a

Prawn::Document.generate("out.pdf", page_size: [page_width, page_height], :margin => [0,0,0,0]) do
  dates.each do |month|
    # Formatting
    fill_color '000000'
    fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
    font('/System/Library/Fonts/HelveticaNeue.ttc', size: 16, style: 'Light')
    fill_color 'FFFFFF'

    text_box "#{DateTime.parse(month[0]).strftime('%B')}", :at => [0, bounds.top / 2], :width => bounds.right, align: :center

    start_new_page

    month.each { |date|
      # Formatting
      fill_color '000000'
      fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
      font('/System/Library/Fonts/HelveticaNeue.ttc', size: 11, style: 'Light')
      fill_color 'FFFFFF'

      # Contents
      text "\n\n"
      image "export/#{page_data[date][:source]}", :position => :center, :fit => [page_width, page_height - 75] #54
      text_box "#{date}: #{page_data[date][:description]}", :at => [0, 40], :width => bounds.right, align: :center
    
      start_new_page
    }
  end
  # Remove the extraneous final page
  delete_page(-1)
end
