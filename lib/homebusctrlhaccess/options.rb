require 'homebus/options'

class HomebusCtrlhAccess::Options < Homebus::Options
  def app_options(op)
  end

  def banner
    'Homebus PDX Hackerspace Access App'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-ctrlh-access'
  end
end
