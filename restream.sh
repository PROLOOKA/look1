#!/bin/bash

# ============= إعدادات متقدمة =============
MAX_RETRIES=999
RETRY_DELAY=10
HLS_DIR="hls"

# ============= ضع روابطك هنا =============
SOURCE_URL="http://gooon.tv:8080/play/link/6aa38f85-dafa-426e-bbd3-20ca86d89ac1/eyJpdiI6Ino0ZnNJZUs3UERoUmFqclBVVDRTUFE9PSIsInZhbHVlIjoiMEpDWlRPaDlXbktiR01IUmVVTitKNW45V1kxWkxKQlVXTGtJWHRRZU1QSnFieXpOSXVKaFd1MXBJV2l4ZjhuUCIsIm1hYyI6IjhhYTljM2E4NTUyZGExZWMxNGYwNGRhNzA4ZjY5MGZiYjBkNWZjYmVhMjQwNjdjZGMyOWI0YmNhN2MyMTQ0ZDciLCJ0YWciOiIifQ==.m3u8"
LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

# ============= User-Agent متقدم =============
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ============= لا تغير شيء أدناه =============
mkdir -p $HLS_DIR
rm -rf $HLS_DIR/*

# تحميل الشعار مع User-Agent
wget -q --user-agent="$USER_AGENT" -O logo.png "$LOGO_URL" || echo "لا يمكن تحميل الشعار"

# حلقة إعادة المحاولة اللامتناهية
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "محاولة رقم: $((RETRY_COUNT+1)) - بدء البث..."
    
    ffmpeg -re -user_agent "$USER_AGENT" -i "$SOURCE_URL" -i logo.png \
    -filter_complex \
    "[1:v]scale=100:-1[logo]; \
     [0:v][logo]overlay=10:main_h-overlay_h-10[v_logo]; \
     [v_logo]split=3[v1][v2][v3]; \
     [v1]scale=1280:720[v1out]; \
     [v2]scale=854:480[v2out]; \
     [v3]scale=640:360[v3out]" \
    -map "[v1out]" -c:v:0 libx264 -b:v:0 2000k -preset ultrafast -g 60 \
    -map "[v2out]" -c:v:1 libx264 -b:v:1 800k -preset ultrafast -g 60 \
    -map "[v3out]" -c:v:2 libx264 -b:v:2 400k -preset ultrafast -g 60 \
    -map 0:a -c:a:0 aac -b:a:0 96k \
    -map 0:a -c:a:1 aac -b:a:1 64k \
    -map 0:a -c:a:2 aac -b:a:2 48k \
    -f hls \
    -hls_time 4 \
    -hls_list_size 10 \
    -hls_flags delete_segments+independent_segments \
    -master_pl_name master.m3u8 \
    -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" \
    $HLS_DIR/v%v.m3u8
    
    # إذا وصل هنا، معناه أن البث توقف
    echo "⚠️ البث توقف! إعادة المحاولة بعد $RETRY_DELAY ثواني..."
    sleep $RETRY_DELAY
    RETRY_COUNT=$((RETRY_COUNT+1))
done
