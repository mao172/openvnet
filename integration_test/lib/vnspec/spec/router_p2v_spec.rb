# -*- coding: utf-8 -*-
require_relative "spec_helper"

describe "router_p2v" do
  describe "pnet" do
    context "mac2mac" do
      it "reachable to pnet" do
        expect(vm1).to be_reachable_to(vm3)
        expect(vm3).to be_reachable_to(vm1)
      end

      it "reachable to vnet" do
        expect(vm1).to be_reachable_to(vm2)
        expect(vm1).to be_reachable_to(vm4)
        expect(vm3).to be_reachable_to(vm2)
        expect(vm3).to be_reachable_to(vm4)
      end
    end

    context "tunnel" do
      it "reachable to vnet" do
        expect(vm1).to be_reachable_to(vm6)
        expect(vm3).to be_reachable_to(vm6)
      end
    end
  end

  describe "vnet" do
    context "mac2mac" do
      it "reachable to pnet" do
        expect(vm2).to be_reachable_to(vm1)
        expect(vm2).to be_reachable_to(vm3)
        expect(vm4).to be_reachable_to(vm1)
        expect(vm4).to be_reachable_to(vm3)
      end

      it "reachable to vnet" do
        expect(vm2).to be_reachable_to(vm4)
        expect(vm4).to be_reachable_to(vm2)
      end
    end

    context "tunnel" do
      it "reachable to pnet" do
        expect(vm6).to be_reachable_to(vm1)
        expect(vm6).to be_reachable_to(vm3)
      end

      it "reachable to vnet" do
        expect(vm2).to be_reachable_to(vm6)
        expect(vm4).to be_reachable_to(vm6)
        expect(vm6).to be_reachable_to(vm2)
        expect(vm6).to be_reachable_to(vm4)
      end
    end
  end
end
