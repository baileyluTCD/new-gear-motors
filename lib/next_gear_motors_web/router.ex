defmodule NextGearMotorsWeb.Router do
  use NextGearMotorsWeb, :router

  import NextGearMotorsWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {NextGearMotorsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'"}
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:next_gear_motors, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: NextGearMotorsWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", NextGearMotorsWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{NextGearMotorsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", NextGearMotorsWeb do
    pipe_through([:browser, :require_admin_user])

    live("/vehicles/new", VehicleLive.Index, :new)
    live("/vehicles/:id/edit", VehicleLive.Index, :edit)
    live("/vehicles/:id/show/edit", VehicleLive.Show, :edit)
  end

  scope "/", NextGearMotorsWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{NextGearMotorsWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_emailA)

      live("/reservations", ReservationLive.Index, :index)
      live("/reservations/vehicles/:vehicle_id/new", ReservationLive.Index, :new)
      live("/reservations/:id/edit", ReservationLive.Index, :edit)
      live("/reservations/:id/messages/:message_id/edit", ReservationLive.Show, :edit_message)
      live("/reservations/:id", ReservationLive.Show, :show)
      live("/reservations/:id/show/edit", ReservationLive.Show, :edit)
    end
  end

  scope "/", NextGearMotorsWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{NextGearMotorsWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end

  scope "/", NextGearMotorsWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/contact", PageController, :contact)
    get("/about", PageController, :about)

    live("/vehicles", VehicleLive.Index, :index)
    live("/vehicles/:id", VehicleLive.Show, :show)
  end
end
