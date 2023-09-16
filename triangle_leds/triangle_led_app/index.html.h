#include <pgmspace.h>

#ifndef _INDEX_HTML_
#define _INDEX_HTML_

const char index_html[] PROGMEM = R"=====(

<!DOCTYPE html>
<html lang="en-US">
  <head>
      <title>Triangle lights manager</title>
      <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=no,shrink-to-fit=no" />
      <style>
        body{
          font-family: Avenir, sans-serif;
          background-color: rgb(245, 245, 245);
          margin: 0px;
          padding: 0px;
          width: 400px;
        }
        svg polygon{
            fill: rgba(255, 255, 255, 0.25);
            stroke-width: 1;
            stroke: rgba(255, 255, 255, 0.3);
        }

        /* svg line{
            stroke: rgba(255, 255, 255, 1.0);
        } */

        #triangles{
            display: inline-block;
            margin-left: 1em;
        }
        #div {
            border: 1px dotted rgba(255, 255, 255, 0.9);
            position: absolute;
            user-select: none;
            -moz-user-select: none;
            -khtml-user-select: none;
            -webkit-user-select: none;
            -o-user-select: none;
        }
        #current_color{
            display: inline-block;
            width: 4em;
            height: 4em;
        }
        select, option{
            font-size: 2em;
        }
        form{
            margin-left: 2em;
        }
        label{
            width: 3em;
            display: inline-block;
            font-size: 1.5em;
            font-weight: bold;
        }
        #palette{
            margin: 0;
            padding: 0;
        }
        #palette li{
          display: inline-block;
          list-style: none;
          border: 2px solid transparent;
        }
        #palette li a{
            display: block;
            width: 4.8em;
            height: 2em;
            margin: 0.2em;
        }
        #palette li.selected{
            border: 2px solid #333333;
        }
        .track-overlay{
            fill: url(#rainbow);
        }
        .form_val{
            display: none;
        }
        #hue_slider .slider line{
            fill: transparent;
            stroke: transparent;
        }
        </style>
    </head>
    <body>

      <div id="div" hidden></div>
      <svg id="triangles" height="340" width="400">
        <defs>
            <linearGradient id="rainbow" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
                <stop offset="17%" style="stop-color:rgb(255,255,0);stop-opacity:1" />
                <stop offset="34%" style="stop-color:rgb(0,255,0);stop-opacity:1" />
                <stop offset="51%" style="stop-color:rgb(0,255,255);stop-opacity:1" />
                <stop offset="68%" style="stop-color:rgb(0,0,255);stop-opacity:1" />
                <stop offset="85%" style="stop-color:rgb(255,0,255);stop-opacity:1" />
                <stop offset="100%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
            </linearGradient>            
        </defs>
      </svg>

      <form>
        <ul id="palette"></ul>

        <p id="hue_value" class="form_val">0</p>
        <div id="hue_slider"></div>

        <p id="sat_value" class="form_val">0.9</p>
        <div id="sat_slider"></div>

        <p id="light_value" class="form_val">0.5</p>
        <div id="light_slider"></div>

        <label for="m">Mode:</label>
        Triangle:<input type="radio" class="mode" name="m" value="Triangle" checked> | 
        Corner:<input type="radio" class="mode" name="m" value="Corner">
        <br />
      </form>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.1.1/d3.min.js"></script>
      <script src="https://unpkg.com/d3-simple-slider@1.10.4/dist/d3-simple-slider.min.js"></script>
      <script src="https://dragselect.com/v2/ds.min.js"></script>
      <script src='https://unpkg.com/@turf/turf@6/turf.min.js'></script>
      <script src="/triangle_lights.js"></script>
    <br />
    <br />
    <a href="/">Home</a>
  </body>
</html>


)=====";
#endif