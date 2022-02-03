--[[
  Themed analog clock by HGS
  Written: 3 February 2022, 13:25 CET by Hendrik G. Seliger (github@hseliger.eu)
  Last changes: 3 February 2022, 20:24 CET by Hendrik G. Seliger (github@hseliger.eu)
  This one should use svg graphics for cairo-clock and render
  them as a clock using conky.
]]

-- theme_name = 'simple-flat-white'
theme_name = 'Timex'

-- Use these settings to define the origin and extent of your clock.
clock_r=90
clock_size=2*clock_r
-- "clock_x" and "clock_y" are the coordinates of the centre of the clock, in pixels, from the top left of the Conky window.
clock_x=100
clock_y=100
--===================================================================================================================
require 'cairo'
require 'rsvg'

function conky_draw_svg_file(f_path,x,y,s,arc)
  -- taken from https://githubmemory.com/repo/brndnmtthws/conky/issues/1144
  -- First check if the file exists
  local f=io.open(f_path,"r")
  if f~=nil then
    io.close(f)
  else
    return -- without drawing anything
  end

  local rh = rsvg_create_handle_from_file(f_path)
  local rd = RsvgDimensionData:create()
  rsvg_handle_get_dimensions(rh, rd)
  iw, ih, em, ex = rd:get()
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual,x+s,y+s)
  local cr = cairo_create (cs)
  cairo_translate (cr, x, y)
  cairo_scale (cr, s/iw, s/ih)
  if arc~=0 then
    cairo_rotate(cr, arc)
  end
  rsvg_handle_render_cairo(rh, cr)
  rsvg_destroy_handle(rh)
  cairo_surface_destroy(cs)
end
--===================================================================================================================
--[[
The files we need to read and draw in this sequence:
clock-drop-shadow.svg
clock-face.svg
clock-marks.svg
clock-face-shadow.svg
clock-glass.svg
clock-frame.svg
clock-hour-hand.svg
clock-hour-hand-shadow.svg
clock-minute-hand.svg
clock-minute-hand-shadow.svg
clock-second-hand.svg
clock-second-hand-shadow.svg
]]

function conky_main()

  if conky_window==nil then return end

  -- variables for time and hand angles
  local mins,hours,secs,secs_arc,mins_arc,hours_arc
  -- file path for svg files
  local f_path
  local dirname  = debug.getinfo(1).source:match("@?(.*/)")
  if dirname==nil then
    dirname="./"
  end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
  local cr=cairo_create(cs)

  secs=os.date("%S")
  mins=os.date("%M")
  hours=os.date("%I")
  -- these angles are right direction, but starting at 0° for 12h,
  -- so later we will have to substract pi/2
  secs_arc=(2*math.pi/60)*secs
  mins_arc=(2*math.pi/60)*mins+secs_arc/60
  hours_arc=(2*math.pi/12)*hours+mins_arc/12
  -- print(hours_arc)

  -- Clock drop shadow
  f_path = dirname .. theme_name .. "/clock-drop-shadow.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)
  -- Clock face
  f_path = dirname .. theme_name .. "/clock-face.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)
  -- Clock marks
  f_path = dirname .. theme_name .. "/clock-marks.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)
  -- Clock face shadow
  f_path = dirname .. theme_name .. "/clock-face-shadow.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)
  -- Clock glass
  f_path = dirname .. theme_name .. "/clock-glass.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)
  -- Clock frame
  f_path = dirname .. theme_name .. "/clock-frame.svg"
  conky_draw_svg_file(f_path,clock_x-clock_r,clock_y-clock_r,clock_size,0)

  -- Hour hand
  f_path = dirname .. theme_name .. "/clock-hour-hand.svg"
  -- as the hands are horizontal in the svg files, we have to change rotation angle by -90°
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,hours_arc-math.pi/2)
  f_path = dirname .. theme_name .. "/clock-hour-hand-shadow.svg"
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,hours_arc-math.pi/2)
  -- Minute hand
  f_path = dirname .. theme_name .. "/clock-minute-hand.svg"
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,mins_arc-math.pi/2)
  f_path = dirname .. theme_name .. "/clock-minute-hand-shadow.svg"
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,mins_arc-math.pi/2)
  -- Second hand
  f_path = dirname .. theme_name .. "/clock-second-hand.svg"
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,secs_arc-math.pi/2)
  f_path = dirname .. theme_name .. "/clock-second-hand-shadow.svg"
  conky_draw_svg_file(f_path,clock_x,clock_y,clock_size,secs_arc-math.pi/2)

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
  collectgarbage()
end
--===================================================================================================================
