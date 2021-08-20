# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::V3::Admin::PluginsController < Api::V3::Admin::ApplicationController
  # before_action :setup_current_tab, only: [:index]

  # GET /admin/plugins
  # GET /admin/plugins.xml
  #----------------------------------------------------------------------------
  def index
    @plugins = FatFreeCRM::Plugin.list

    respond_with(@plugins)
  end
end
