Factory.define :wiki_content do |f|
  f.text 'some text'
  f.association :wiki_page, :factory => :wiki_page
end
