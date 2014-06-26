module Vnet::NodeApi
  class IpRetentionContainer < Base
    class << self
      def create(options)
        super.tap do |ip_retention_container|
          dispatch_event(IP_RETENTION_CONTAINER_CREATED_ITEM, ip_retention_container.to_hash)
        end
      end

      def destroy(uuid)
        super.tap do |ip_retention_container|
          dispatch_event(IP_RETENTION_CONTAINER_CREATED_ITEM, ip_retention_container.to_hash)
        end
      end

      def add_ip_retention(id, options)
        ip_retention_container = model_class[id]

        ip_retention = nil
        transaction do
          ip_retention = ip_retention_container.add_ip_retention(ip_lease_id: options[:ip_lease_id])
        end

        dispatch_event(IP_RETENTION_CONTAINER_ADDED_IP_RETENTION, id: id, ip_retention_id: ip_retention.id, ip_lease_id: ip_retention.ip_lease_id, leased_at: ip_retention.leased_at)

        ip_retention
      end

      def remove_ip_retention(id, ip_retention_id)
        ip_retention = model_class(:ip_retention)[ip_retention_id]

        return unless ip_retention.ip_retention_container_id == id

        transaction do
          ip_retention.destroy
        end

        dispatch_event(IP_RETENTION_CONTAINER_REMOVED_IP_RETENTION, id: id, ip_retention_id: ip_retention_id)

        ip_retention
      end
    end
  end
end