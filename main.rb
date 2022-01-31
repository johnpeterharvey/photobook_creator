require 'prawn'
require 'prawn/emoji'
require 'json'
require 'date'

current_year = 2021

page_width = 693
page_height = 594
height_subtract = 38
text_position = 30

page_data = {}
feed_file = File.open 'export/feed.json'
data = JSON.load feed_file

# Init the page data with no image blanks
(Date.new(current_year, 1, 1)..Date.new(current_year, 12, 31)).to_a.each do |date|
  page_data[date.strftime('%Y-%m-%d')] = {:description => "Nothing Posted", :source => "no_image.png"}
end

# For all the items posted, iterate through
data['items'].each do |item|
  item_date = DateTime.parse(item['date_published']).strftime('%Y-%m-%d')
  item_description = /<p>([^<]+)/.match(item['content_html'])[1].gsub("\n", ', ')
  image_source = /src=\"([^\"]+)/.match(item['content_html'])[1]
  page_data[item_date] = {:description => item_description, :source => "export/#{image_source}"}
end

# Filter to only the required year, and slice into an array of arrays by month
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
      puts date
      # Formatting
      fill_color '000000'
      fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
      font('/System/Library/Fonts/HelveticaNeue.ttc', size: 10, style: 'Light')
      fill_color 'FFFFFF'

      # Contents
      text "\n"

      # Image
      bounding_box([0, page_height], width: page_width, height: page_height - height_subtract) do
        image "#{page_data[date][:source]}", :position => :center, :vposition => :center, :fit => [page_width, page_height - height_subtract]
      end
      # Image description
      text_box "#{date}: #{page_data[date][:description]}", :at => [0, text_position], :width => bounds.right, align: :center

      start_new_page
    }
  end
  # Final page
  if (dates.length % 2) then
    puts "Odd number of pages, adding final blank page"
    fill_color '000000'
    fill_rectangle [bounds.left, bounds.top], bounds.right, bounds.top
  else
    puts "Even number of pages, removing extraneous extra"
    delete_page(-1)
  end
end
