module Tasks
  def self.subscriber_report
    msg = ["\n### Subscribers report ###"]
    subscribers = Subscriber.all
    subscriptions = Subscription.all

    summary = {
      subscribers: subscribers.size,
      sites: Site.all.size,
      subs: subscriptions.size,
      site_subs: SiteSubscription.all.size
    }

    subscribers.order(:id).each do |subscriber|
      sites = subscriber.sites

      msg << "\n#{subscriber.id}. #{subscriber.name} (#{subscriber.email}) - " + sites.size.to_s + " sites"
      pad1 = " " * (subscriber.id.to_s.length + 2)

      sites.order(:id).each do |site|
        site_subs = site.subscriptions

        msg << pad1 + "#{site.id}. #{site.name} (#{site.latitude}, #{site.longitude}) - " + site_subs.size.to_s + " subs"
        pad2 = pad1 + " " * (site.id.to_s.length + 2)

        site_subs.order(:id).each do |s|
          msg << pad2 + "#{s.id}. #{s.name}"
        end
      end
    end

    msg << "\n### Subscriptions available ###\n"
    subscriptions.order(:id).each do |s|
      msg << "#{s.id}. #{s.name} (#{s.type}) - " + s.sites.size.to_s + " sites"
    end

    msg << "\n### Summary ###\n"
    msg << "Subscribers: #{summary[:subscribers]}"
    msg << "Sites: #{summary[:sites]}"
    msg << "Subscriptions available: #{summary[:subs]}"
    msg << "Site subscriptions: #{summary[:site_subs]}"

    puts msg.join("\n")
  end

  def self.subscribe_all_sites_to_weather
    msg = []
    Site.all.each do |site|
      site.subscriptions << Subscription.weather.first
      msg << "  Added weather subscription to " + site.name
    rescue
      msg << "  " + site.name + " is already subscribed"
      next
    end
    puts msg.join("\n")
  end

  def self.purge_subs(delete: false)
    unconfirmed = Subscriber.unconfirmed.where("updated_at < ?", 1.week.ago)
    stale = Subscriber.stale
    puts "Total subscribers: #{Subscriber.all.size}. Unconfirmed: #{unconfirmed.size}. Stale: #{stale.size}."
    if delete
      unconfirmed.destroy_all
      stale.destroy_all
    else
      puts "Run with delete:true to delete unconfirmed/stale subscriber records."
      {unconfirmed:, stale:}
    end
  end
end
