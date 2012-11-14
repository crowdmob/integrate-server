module CrowdMob
  class << self
    attr_accessor :base_url
  end

  # You can test against CrowdMob's staging server located at:
  @base_url = 'http://deals.mobstaging.com'

  # Eventually, you'll want to switch over to CrowdMob's production server
  # located at:
  # @base_url = 'https://deals.crowdmob.com'
end
