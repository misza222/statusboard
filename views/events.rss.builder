url = "#{request.scheme}://#{request.host}/#{@service.id}/"

xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
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
