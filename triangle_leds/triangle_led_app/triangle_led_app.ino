#include <Adafruit_NeoPixel.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define LED_PIN 4
#define PIXELS_PER_CORNER 4
#define CORNER_COUNT 39
#define SEGMENT_ATTR_COUNT 13
#define LED_COUNT CORNER_COUNT * PIXELS_PER_CORNER

#define POS_BOTTOM 1
#define POS_TOPLEFT 2
#define POS_TOPRIGHT 3

#define POS_BOTTOMLEFT 6
#define POS_TOP 5
#define POS_BOTTOMRIGHT 4

#define OR_UP 1
#define OR_DOWN 2
#define FIELD_DIST_MIDDLE 11
#define FIELD_Y 7
#define FIELD_X 6

uint32_t r(uint32_t c){
    return (c & 0x00ff0000) >> 16;
}

uint32_t g(uint32_t c){
    return (c & 0x0000ff00) >> 8;
}

uint32_t b(uint32_t c){
    return (c & 0x000000ff);
}

float offset = 0;

uint8_t corners [CORNER_COUNT][SEGMENT_ATTR_COUNT] = {
{0,1,0,POS_TOP,0,19,4,4,2,3,0,3,OR_UP},
{0,1,1,POS_BOTTOMLEFT,1,18,3,5,2,3,1,6,OR_UP},
{0,1,2,POS_BOTTOMRIGHT,2,20,5,5,2,3,1,7,OR_UP},
{1,1,3,POS_BOTTOM,0,16,5,5,2,4,1,7,OR_DOWN},
{1,1,4,POS_TOPRIGHT,1,15,6,4,2,4,1,7,OR_DOWN},
{1,1,5,POS_TOPLEFT,2,17,4,4,2,4,0,4,OR_DOWN},
{2,0,6,POS_BOTTOMRIGHT,0,14,6,3,1,4,1,7,OR_UP},
{2,0,7,POS_TOP,1,13,5,2,1,4,1,6,OR_UP},
{2,0,8,POS_BOTTOMLEFT,2,12,4,3,1,4,0,3,OR_UP},
{3,1,9,POS_BOTTOM,0,25,4,3,1,3,0,2,OR_DOWN},
{3,1,10,POS_TOPLEFT,1,24,3,2,1,3,0,2,OR_DOWN},
{3,1,11,POS_TOPRIGHT,2,26,5,2,1,3,1,5,OR_DOWN},
{4,0,12,POS_BOTTOMRIGHT,0,23,5,1,0,3,1,6,OR_UP},
{4,0,13,POS_TOP,1,21,4,0,0,3,1,7,OR_UP},
{4,0,14,POS_BOTTOMLEFT,2,22,3,1,0,3,0,3,OR_UP},
{5,0,15,POS_TOPRIGHT,0,38,5,0,0,2,1,7,OR_DOWN},
{5,0,16,POS_TOPLEFT,1,37,3,0,0,2,1,7,OR_DOWN},
{5,0,17,POS_BOTTOM,2,36,4,1,0,2,0,4,OR_DOWN},
{6,0,18,POS_TOP,0,10,2,0,0,1,1,7,OR_UP},
{6,0,19,POS_BOTTOMLEFT,1,11,1,1,0,1,1,6,OR_UP},
{6,0,20,POS_BOTTOMRIGHT,2,9,3,1,0,1,0,3,OR_UP},
{7,0,21,POS_TOPLEFT,0,8,1,2,1,1,0,2,OR_DOWN},
{7,0,22,POS_BOTTOM,1,7,2,3,1,1,0,2,OR_DOWN},
{7,0,23,POS_TOPRIGHT,2,6,3,2,1,1,1,5,OR_DOWN},
{8,1,24,POS_TOP,0,27,1,2,1,0,1,6,OR_UP},
{8,1,25,POS_BOTTOMLEFT,1,29,0,3,1,0,1,7,OR_UP},
{8,1,26,POS_BOTTOMRIGHT,2,28,2,3,1,0,0,3,OR_UP},
{9,1,27,POS_TOPLEFT,0,30,0,4,2,0,1,7,OR_DOWN},
{9,1,28,POS_BOTTOM,1,32,1,5,2,0,1,7,OR_DOWN},
{9,1,29,POS_TOPRIGHT,2,31,2,4,2,0,0,4,OR_DOWN},
{10,0,30,POS_BOTTOMLEFT,0,35,1,5,2,1,1,7,OR_UP},
{10,0,31,POS_BOTTOMRIGHT,1,34,3,5,2,1,1,6,OR_UP},
{10,0,32,POS_TOP,2,33,2,4,2,1,0,3,OR_UP},
{11,1,33,POS_BOTTOM,0,1,4,5,2,2,1,5,OR_DOWN},
{11,1,34,POS_TOPRIGHT,1,0,5,4,2,2,0,2,OR_DOWN},
{11,1,35,POS_TOPLEFT,2,2,3,4,2,2,0,2,OR_DOWN},
{12,0,36,POS_BOTTOMRIGHT,0,5,5,3,1,2,0,1,OR_UP},
{12,0,37,POS_TOP,1,4,4,2,1,2,0,1,OR_UP},
{12,0,38,POS_BOTTOMLEFT,2,3,3,3,1,2,0,1,OR_UP}
};

Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

uint32_t color(uint8_t r, uint8_t g, uint8_t b){
  return ((uint32_t)r << 16) | ((uint32_t)g << 8) | b;
}

uint32_t color_blend(uint32_t color1, uint32_t color2, uint8_t blendAmt) {
  uint32_t blendedColor;
  blend((uint8_t*)&blendedColor, (uint8_t*)&color1, (uint8_t*)&color2, sizeof(uint32_t), blendAmt);
  return blendedColor;
}

uint8_t* blend(uint8_t *dest, uint8_t *src1, uint8_t *src2, uint16_t cnt, uint8_t blendAmt) {
  if(blendAmt == 0) {
    memmove(dest, src1, cnt);
  } else if(blendAmt == 255) {
    memmove(dest, src2, cnt);
  } else {
    for(uint16_t i=0; i<cnt; i++) {
//    dest[i] = map(blendAmt, 0, 255, src1[i], src2[i]);
      dest[i] =  blendAmt * ((int)src2[i] - (int)src1[i]) / 256 + src1[i]; // map() function
    }
  }
  return dest;
}

uint32_t show_colors[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

uint32_t test_colors[13] = {
    color(255, 2, 0), // red
    color(0, 0, 0),
    color(255, 60, 0), // orange
    color(0, 0, 0),
    color(255, 160, 0), // yellow
    color(0, 0, 0),
    color(0, 0, 0),
    color(0, 160, 255),
    color(0, 80, 255),
    color(0, 40, 255),
    color(0, 20, 255),
    color(0, 10, 255),
    color(0, 0, 0)
};

void color_test(){
    for(int i = 0; i < CORNER_COUNT; i += 1){
        uint8_t *corner = corners[i];
        uint32_t c = test_colors[corner[0] % 13];
        for(int p = 0; p < PIXELS_PER_CORNER; p += 1){
            strip.setPixelColor(i*PIXELS_PER_CORNER + p, r(c), g(c), b(c));
        }
    }
    offset += 0.1;
    delay(50);

}

void fader(uint32_t *colors, int color_count, int field, int delay_ms){
    for(int i = 0; i < color_count; i++){
        uint32_t c1 = colors[(int)floor(i) % color_count];
        uint32_t c2 = colors[(int)floor(i+1) % color_count];
        show_colors[i] = color_blend(c1, c2, fmod(offset, 1) * 255);
    }
    for(int i = 0; i < CORNER_COUNT; i += 1){
        uint8_t *corner = corners[i];
        uint32_t c = show_colors[(int)floor(corner[field]+offset) % color_count];
        for(int p = 0; p < PIXELS_PER_CORNER; p += 1){
            strip.setPixelColor(i*PIXELS_PER_CORNER + p, r(c), g(c), b(c));
        }
    }
    offset += 0.1;
    delay(delay_ms);
}

void setup() {
    // memcpy(show_colors, colors, 6*sizeof(uint32_t));
    Serial.begin(115200);
    strip.begin();
    strip.setBrightness(255);
    strip.show();
}


void loop(){
    uint32_t colors[5] = {
        color(255, 2, 0), // red
        color(255, 60, 0), // orange
        color(255, 140, 0), // yellow
        color(255, 140, 0), // yellow
        color(255, 60, 0), // orange
    };
//    triange_loops();
    fader(colors, 5, FIELD_Y, 30);
//    color_test();
    strip.show();
}

// #include <ESP8266WiFi.h>
// #include <ESP8266WebServer.h>
// #include <WS2812FX.h>
// #include "index.html.h"
// #include "triangle_lights.js.h"

// #define WEB_SERVER ESP8266WebServer
// #define ESP_RESET ESP.reset()
// #define WIFI_SSID "The Old Internet 2.4G"
// #define WIFI_PASSWORD "snowboarding"
// #define LED_PIN 4
// #define WIFI_TIMEOUT 30000
// #define HTTP_PORT 80
// #define MAX_SEGMENTS 39
// #define PIXELS_PER_CORNER 4
// #define LED_COUNT MAX_SEGMENTS * PIXELS_PER_CORNER
// #define SEGMENT_ATTR_COUNT 10
// #define min(a,b) ((a)<(b)?(a):(b))
// #define max(a,b) ((a)>(b)?(a):(b))

// unsigned long last_wifi_check_time = 0;



// WS2812FX ws2812fx = WS2812FX(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800, MAX_SEGMENTS, MAX_SEGMENTS);
// WEB_SERVER server(HTTP_PORT);

// uint32_t color(uint8_t r, uint8_t g, uint8_t b){
//   return ((uint32_t)r << 16) | ((uint32_t)g << 8) | b;
// }

// void setup() {
//   Serial.begin(115200);
//   delay(100);
//   ws2812fx.init();
//   ws2812fx.setBrightness(255);
//   for(int i=0; i<MAX_SEGMENTS; i+=1){
//     ws2812fx.setSegment(i, i*PIXELS_PER_CORNER, (i+1)*PIXELS_PER_CORNER-1, FX_MODE_STATIC, color(20, 20, 40));
//   }
//   ws2812fx.start();
//   wifi_setup(); 
//   server.on("/", srv_index);
//   server.on("/triangle_lights.js", http_triangle_lights_js);
//   server.begin();
// }

// void loop() {
//   unsigned long now = millis();

//   server.handleClient();
//   ws2812fx.service();

//   if(now - last_wifi_check_time > WIFI_TIMEOUT) {
//     Serial.print("Checking WiFi... ");
//     if(WiFi.status() != WL_CONNECTED) {
//       Serial.println("WiFi connection lost. Reconnecting...");
//       wifi_setup();
//     } else {
//       Serial.println("OK");
//     }
//     last_wifi_check_time = now;
//   }
//   uint32_t tri_color[3] = {color(255, 10, 0), color(255, 30, 10), color(0, 20, 255)};
//   for(int i=0; i<MAX_SEGMENTS; i+1){
//       // corners[i][3]
//       ws2812fx.setColor(i, tri_color[0]);
//   }
// }


// void srv_index() {
//   uint32_t seg_colors[3] = {color(20, 20, 20), color(20, 20, 20), color(20, 20, 20)};
//   uint8_t color_num = 0;
//   uint16_t spd = 2000;
//   uint8_t mde = 0;
//   uint8_t opt = 2;
//   uint8_t corner = 0;
//   uint8_t show = 0;
//   bool set_colors = false;
//   for (uint8_t i=0; i < server.args(); i++){
//     if(strlen(server.arg(i).c_str()) > 0){
//         if(server.argName(i) == "colors"){
//             // char * token = strtok(server.arg(i).c_str(), ",");
//             //while( token != NULL ) {
//             uint8_t seg = 0;
//             char * token;
//             // char ** all_colors = server.arg(i).c_str();
//             char * all_colors = new char [server.arg(i).length()+1];
//             std::strcpy (all_colors, server.arg(i).c_str());
//             while ((token = strsep(&all_colors, ","))){
//                 uint32_t colr = (uint32_t) strtol(token, NULL, 16);
//                 ws2812fx.setSegment(seg, seg*4, seg*4+3, FX_MODE_STATIC, colr);
//                 token = strtok(NULL, ",");
//                 seg += 1;
//             }
//             set_colors = true;       
//         }
//         else if(server.argName(i)[0] == 'show') {
//             show = (uint8_t) strtol(server.arg(i).c_str(), NULL, 10);
//         }
//         else if(server.argName(i)[0] == 'c') {
//             uint32_t colr = (uint32_t) strtol(server.arg(i).c_str(), NULL, 16);
//             seg_colors[color_num++] = colr;
//         }
//         else if(server.argName(i) == "s") {
//             spd = (uint16_t) strtol(server.arg(i).c_str(), NULL, 10);
//         }
//         else if(server.argName(i) == "m") {
//             mde = (uint8_t) strtol(server.arg(i).c_str(), NULL, 10);
//         }
//         else if(server.argName(i) == "o") {
//             opt = (uint8_t) strtol(server.arg(i).c_str(), NULL, 10);
//         }
//         else if(server.argName(i) == "co"){
//             corner = (uint8_t) strtol(server.arg(i).c_str(), NULL, 10);
//         }
//     }
//   }
// //   Serial.print(corners[corner][0]);
// //   Serial.print("m: ");Serial.print(mde);
// //   Serial.print("  c: ");Serial.print(seg_colors[0]);
// //   Serial.print("  s: ");Serial.print(spd);
// //   Serial.print("  o: ");Serial.print(opt);
// //   Serial.println();
//   if(show > 0){
//     // for(int i = 0; i += 3; i < MAX_SEGMENTS){
//     //     // uint8_t corner[9] =  corners[i];
//     //     // ws2812fx.setSegment(corner[], 0, LED_COUNT, mde, seg_colors, spd, opt);
//     // }
//   }
//   else if(!set_colors){
//     ws2812fx.setSegment(0, 0, LED_COUNT, mde, seg_colors, spd, opt);
//   }
//   server.send(200, "text/html", index_html);
// }

// void http_triangle_lights_js(){
//       server.send(200, "text/html", triangle_lights_js);
// }

// void wifi_setup() {
//   Serial.println();
//   Serial.print("Connecting to ");
//   Serial.println(WIFI_SSID);

//   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
//   WiFi.mode(WIFI_STA);
//   #ifdef STATIC_IP  
//     WiFi.config(ip, gateway, subnet);
//   #endif

//   unsigned long connect_start = millis();
//   while(WiFi.status() != WL_CONNECTED) {
//     delay(100);
//     Serial.print(".");

//     if(millis() - connect_start > WIFI_TIMEOUT) {
//       Serial.println();
//       Serial.print("Tried ");
//       Serial.print(WIFI_TIMEOUT);
//       Serial.print("ms. Resetting ESP now.");
//       ESP_RESET;
//     }
//   }

//   Serial.println("");
//   Serial.println("WiFi connected");  
//   Serial.print("IP address: ");
//   Serial.println(WiFi.localIP());
//   Serial.println();
// }

