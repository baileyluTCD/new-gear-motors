defmodule NextGearMotorsWeb.PageControllerTest do
  use NextGearMotorsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Built for the road."
    assert html_response(conn, 200) =~ "Priced for you."
  end

  test "GET /contact", %{conn: conn} do
    conn = get(conn, ~p"/contact")
    assert html_response(conn, 200) =~ "Contact Information"
  end

  test "GET /about", %{conn: conn} do
    conn = get(conn, ~p"/about")
    assert html_response(conn, 200) =~ "About Us"
  end

  test "GET /privacy", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    assert html_response(conn, 200) =~ "PRIVACY POLICY"
  end

  test "GET /cookies", %{conn: conn} do
    conn = get(conn, ~p"/cookies")
    assert html_response(conn, 200) =~ "COOKIE POLICY"
  end

  test "GET not found route", %{conn: conn} do
    conn = get(conn, ~p"/not_found")
    assert html_response(conn, 200) =~ "Page Not Found"

    conn = get(conn, ~p"/not_found1")
    assert html_response(conn, 200) =~ "Page Not Found"
  end
end
