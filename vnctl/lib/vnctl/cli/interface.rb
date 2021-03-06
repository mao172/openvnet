# -*- coding: utf-8 -*-

module Vnctl::Cli
  class Interface < Base
    namespace :interfaces
    api_suffix "interfaces"

    add_modify_shared_options {
      option :ingress_filtering_enabled, :type => :boolean,
        :desc => "Flag that decides whether or not ingress filtering (security groups) is enabled."
      option :enable_routing, :type => :boolean,
        :desc => "Flag that decides whether or not routing is enabled."
      option :enable_route_translation, :type => :boolean,
        :desc => "Flag that decides whether or not route translation is enabled."
      option :owner_datapath_uuid, :type => :string,
        :desc => "The uuid of the datapath that owns this interface."
    }

    option_uuid
    add_modify_shared_options
    option :network_uuid, :type => :string, :desc => "The uuid of the network this interface is in."
    option :mac_address, :type => :string, :desc => "The mac address for this interface."
    option :ipv4_address, :type => :string, :desc => "The first ip lease for this interface."
    option :port_name, :type => :string, :desc => "The port name for this interface."
    option :mode, :type => :string, :desc => "The type of this interface."
    define_add

    add_modify_shared_options
    define_modify

    define_show
    define_del
    define_rename

    define_relation :security_groups

  end
end
