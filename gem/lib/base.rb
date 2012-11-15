module CrowdMob
  class << self
    attr_accessor :env
  end

  @env = :development

  def self.base_url
    @env == :production ? 'http://deals.crowdmob.com' : 'http://deals.mobstaging.com'
  end
end
