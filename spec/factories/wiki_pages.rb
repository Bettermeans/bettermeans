Factory.define :wiki_page do |f|
  f.association :wiki, :factory => :wiki
end
