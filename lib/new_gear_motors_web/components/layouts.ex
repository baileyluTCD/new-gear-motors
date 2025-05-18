defmodule NewGearMotorsWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use NewGearMotorsWeb, :controller` and
  `use NewGearMotorsWeb, :live_view`.
  """
  use NewGearMotorsWeb, :html

  embed_templates "layouts/*"
end
