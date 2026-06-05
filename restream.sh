#!/bin/bash

mkdir -p hls
rm -rf hls/*

# الرابط الجديد
SOURCE_URL="http://gooon.tv:8080/play/link/6aa38f85-dafa-426e-bbd3-20ca86d89ac1/eyJpdiI6Ino0ZnNJZUs3UERoUmFqclBVVDRTUFE9PSIsInZhbHVlIjoiMEpDWlRPaDlXbktiR01IUmVVTitKNW45V1kxWkxKQlVXTGtJWHRRZU1QSnFieXpOSXVKaFd1MXBJV2l4ZjhuUCIsIm1hYyI6IjhhYTljM2E4NTUyZGExZWMxNGYwNGRhNzA4ZjY5MGZiYjBkNWZjYmVhMjQwNjdjZGMyOWI0YmNhN2MyMTQ0ZDciLCJ0YWciOiIifQ==.m3u8"

LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

wget -q -O logo.png "$LOGO_URL"

while true; do
  ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5 -i "$SOURCE_URL" -i logo.png \
  -filter_complex "[1:v]scale=80:-1[logo];[0:v][logo]overlay=10:main_h-overlay_h-10" \
  -c:v libx264 -preset superfast -tune zerolatency -b:v 1500k -maxrate 1500k -bufsize 3000k \
  -s 854x480 -c:a aac -b:a 128k -ac 2 -ar 44100 -g 50 -sc_threshold 0 \
  -f hls -hls_time 2 -hls_list_size 10 -hls_flags delete_segments \
  -master_pl_name master.m3u8 \
  hls/master.m3u8
  
  echo "البث انقطع، إعادة تشغيل خلال 5 ثوان..."
  sleep 5
done
