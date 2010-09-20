url = "#{request.scheme}://#{request.host}/#{@service.id}/"

xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0", :'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.atom :link, :href => "#{url}?format=rss",
             :rel => 'self', :type => 'application/rss+xml'
    xml.title @service.name
    xml.description @service.description
    xml.link url

    @events.each do |event|
      xml.item do
        xml.title event.name
        xml.description event.description
        
        xml.link "#{url}"
        xml.guid "#{url}#{event.id}/"
        
        xml.pubDate Time.parse(event.created_at.to_s).rfc822()
      end
    end
  end
end
