require 'spec_helper'
require 'ipaddress'

describe Vnet::NodeApi::LeasePolicy do
  before do
    use_mock_event_handler
  end

  describe ".schedule" do
    let(:network) { Fabricate(:network_for_range) }

    context "when running out of ip addresses" do
      let(:ip_range_group) do
        Fabricate(:ip_range_group_with_range) { allocation_type "incremental" }
      end

      before do
        10.times {
          ipv4_address = Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group)
          Vnet::Models::IpAddress.create(network: network, ipv4_address: ipv4_address)
        }
      end

      it "raise 'Run out of dynamic IP addresses' error" do
        expect { Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group) }.to raise_error(/Run out of dynamic IP addresses/)
      end
    end

    context "when allocation_type is :incremental" do
      let(:ip_range_group) do
        Fabricate(:ip_range_group_with_range) { allocation_type "incremental" }
      end

      it "returns an ipv4 address by incremental order" do
        ipv4_address = Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group)
        expect(IPAddress::IPv4.parse_u32(ipv4_address).to_s).to eq "10.102.0.101"
      end
    end

    context "when allocation_type is :decremental" do
      let(:ip_range_group) do
        Fabricate(:ip_range_group_with_range) { allocation_type "decremental" }
      end

      it "returns an ipv4 address by decremental order" do
        ipv4_address = Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group)
        expect(IPAddress::IPv4.parse_u32(ipv4_address).to_s).to eq "10.102.0.110"
      end
    end

    context "when allocation_type is :random" do
      let(:ip_range_group) do
        Fabricate(:ip_range_group_with_range) { allocation_type "random" }
      end

      it "raise NotImplementedError" do
        expect { Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group) }.to raise_error(NotImplementedError)
      end
    end

    # network:
    #   ipv4_address: 10.102.0.100
    #   prefix 3
    #   begin: 10.102.0.101
    #   end:   10.102.0.102
    #
    # ip_range:
    #   prefix: 24
    #   begin: 10.102.0.100
    #   end: 10.102.0.110
    #
    context "when ip_range's ipv4_prefix is different from network's ipv4_prefix" do
      let(:network) { Fabricate(:network_with_prefix_30) }
      let(:ip_range_group) do
        Fabricate(:ip_range_group_with_range) { allocation_type "incremental" }
      end

      it "returns the ip addresses within the network's subnet" do

        Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group).tap do |ipv4_address|
          expect(IPAddress::IPv4.parse_u32(ipv4_address).to_s).to eq "10.102.0.101"
          Vnet::Models::IpAddress.create(network: network, ipv4_address: ipv4_address)
        end

        Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group).tap do |ipv4_address|
          expect(IPAddress::IPv4.parse_u32(ipv4_address).to_s).to eq "10.102.0.102"
          Vnet::Models::IpAddress.create(network: network, ipv4_address: ipv4_address)
        end

        expect { Vnet::NodeApi::LeasePolicy.schedule(network, ip_range_group) }.to raise_error(/Run out of dynamic IP addresses/)
      end
    end
  end

  describe ".allocate_ip" do
    let(:lease_policy) { Fabricate(:lease_policy_with_network) }
    let(:interface) { Fabricate(:interface_w_mac_lease) }

    it "allocate new ip to an interface" do
      Vnet::NodeApi::LeasePolicy.allocate_ip(
        lease_policy_id: lease_policy.id,
        interface_id: interface.id
      )

      ip_lease = interface.ip_leases.first
      expect(IPAddress::IPv4.parse_u32(ip_lease.ipv4_address).to_s).to eq "10.102.0.101"

      event = MockEventHandler.handled_events.first
      expect(event[:event]).to eq Vnet::Event::INTERFACE_LEASED_IPV4_ADDRESS
      expect(event[:options][:id]).to eq interface.id
      expect(event[:options][:ip_lease_id]).to eq ip_lease.id
    end
  end
end