# -*- coding: utf-8 -*-
require_relative "spec_helper"

describe "security groups" do
  describe "rule" do
    describe "tcp:22:10.101.0.11" do
      # No need to listen on tcp port 22 since SSH is already up there

      it "accepts incoming tcp packets on port 22 from '10.101.0.11/32'" do
        expect(vm3).to be_reachable_to(vm1)
      end

      it "blocks other ip addresses" do
        expect(vm5).not_to be_reachable_to(vm1)
      end

      it "Blocks other ports" do
        vm1.tcp_listen(222)
        expect(vm3).not_to be_able_to_send_tcp(vm1, 222)
        vm1.tcp_close(222)
      end
    end

    describe "icmp:-1:10.101.0.11" do
      it "accepts incoming icmp from '10.101.0.11/32'" do
        expect(vm3).to be_able_to_ping(vm1)
      end

      it "blocks everything else" do
        expect(vm5).not_to be_able_to_ping(vm1)
      end
    end

    describe "udp:344:10.101.0.11" do
      # Using before each instead of before all because netcat binds its
      # UDP process to the source ip/port of the first datagram it receives.
      before(:each) do
        vm1.udp_listen(344)
      end

      after(:each) do
        vm1.udp_close(344)
      end

      it "accepts incoming udp packets on port 344 from '10.101.0.11/32h'" do
        expect(vm3).to be_able_to_send_udp(vm1, 344)
      end

      it "Blocks other ports" do
        vm1.udp_listen(345)
        expect(vm3).not_to be_able_to_send_udp(vm1, 345)
        vm1.udp_close(345)
      end

      it "Blocks other ip addresses" do
        expect(vm5).not_to be_able_to_send_udp(vm1, 344)
      end
    end

    describe "icmp:-1:0.0.0.0/0" do
      it "accepts incoming icmp from everywhere" do
        expect(vm4).to be_able_to_ping(vm2)
        expect(vm6).to be_able_to_ping(vm2)
      end
    end
  end

  describe "connection tracking" do
    it "accepts incoming packets on ports that outgoing tcp packets passed through" do
      expect(vm1).to be_reachable_to(vm3)
    end
  end
end
