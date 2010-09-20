url = "#{request.scheme}://#{request.host}/"

xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0", :'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.atom :link, :href => 'http://dallas.example.com/rss.xml',
           :rel => 'self', :type => 'application/rss+xml'
  xml.channel do
    xml.title settings.board_name
    xml.description settings.board_description
    
    xml.link url

    @services.each do |service|
      xml.item do
        xml.title service.name
        xml.description service.description
        
        xml.link "#{url}#{service.id}/"
        xml.guid "#{url}#{service.id}/"
        
        xml.pubDate Time.parse(service.created_at.to_s).rfc822()
      end
    end
  end
end
