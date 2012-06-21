xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Latest Updates"
    xml.description "Subscribed Alerts from #{APP_CONFIG[:core_settings][:app_name].to_s}"
    xml.link account_comments_url(@user)

    for comment in @records
      xml.item do
        xml.title comment.source
        xml.description comment.message
        xml.pubDate comment.created_at.to_s(:rfc822)
        xml.link account_comments_url(@user)
      end
    end
  end
end