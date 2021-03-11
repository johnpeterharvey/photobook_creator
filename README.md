# Photobook Creator

Takes an export blog dump from micro.blog, and creates a PDF for printing a physical photobook.

### Caveats

- This was created for printing my photo a day blog, and expects one entry per day. Multiple entries per day will be ignored.
- The PDF is output with the sizing for photobooks printed on [Blurb](blurb.co.uk).
- Front and rear cover PDF need to be generated manually using the keynote document `Front & Rear Cover.key`.

### Steps

- On micro.blog, navigate to Posts -> Export -> Export new archive (.bar)
- Expand this into the code directory within the `./export/` directory
- Verify the files `./export/feed.json` and `./export/uploads/{YEAR}/{IMAGES}` exist
- `bundle install`
- Edit `current_year` in main.rb
- `ruby main.rb`
- See output `out.pdf`
