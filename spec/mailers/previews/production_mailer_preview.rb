# frozen_string_literal: true

class ProductionMailerPreview < ActionMailer::Preview
  def consumer_production_access
    ProductionMailer.consumer_production_access(request)
  end

  def support_production_access
    ProductionMailer.support_production_access(request)
  end

  private

  def request
    {
      organization: 'Origami Door to Door Sales',
      primaryContact: {
        email: 'origami_sales@door_2_door.com',
        firstName: 'Mark',
        lastName: 'Origamino'
      }
    }
  end
end
