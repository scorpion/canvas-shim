Announcement.class_eval do
  def self.reorder_pinned_announcements(order_params)
    order_params.each do |k, v|
      announcement = self.find(k)
      next unless announcement
      announcement.update(position: v)
    end
  end

  def add_pin(pin_announcements)
    if pin_announcements.include?(id.to_s)
      update(pinned: true) unless pinned
    end
  end

  def remove_pin(pin_announcements)
    if pin_announcements.include?(id.to_s)
      update(pinned: false) if pinned
    end
  end

  def expiration_date?
    @expiration_date ||= SettingsService.get_settings(object: :announcement, id: id)['expiration_date']
  end

  def is_expired?
    expiration_date? && Time.now > DateTime.parse(expiration_date?)
  end
end