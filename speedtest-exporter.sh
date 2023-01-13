#!/bin/bash
set -e
set -o pipefail

function printMetric {
    echo "# HELP $1 $2"
    echo "# TYPE $1 $3"
    echo "$1$5 $4"
}

speedtest_args=()
speedtest_args+=("--accept-license")
speedtest_args+=("--accept-gdpr")
speedtest_args+=("--format=tsv")

if [[ "x$1" != "x" ]];then
  speedtest_args+=("--server-id=$1")
fi

timeout "${SCRIPT_TIMEOUT:-60}" /usr/local/bin/speedtest "${speedtest_args[@]}" | while IFS=$'\t' read -r servername serverid latency jitter packetloss download upload downloadedbytes uploadedbytes rest; do
    common_labels="{servername=\"$servername\",serverid=\"$serverid\"}"
    printMetric "speedtest_latency_seconds" "Latency" "gauge" "$latency" "$common_labels"
    printMetric "speedtest_jittter_seconds" "Jitter" "gauge" "$jitter" "$common_labels"
    printMetric "speedtest_packet_loss" "Packet Loss" "gauge" "$packetloss" "$common_labels"
    printMetric "speedtest_download_bytes" "Download Speed" "gauge" "$download" "$common_labels"
    printMetric "speedtest_upload_bytes" "Upload Speed" "gauge" "$upload" "$common_labels"
    printMetric "speedtest_downloadedbytes_bytes" "Downloaded Bytes" "gauge" "$downloadedbytes" "$common_labels"
    printMetric "speedtest_uploadedbytes_bytes" "Uploaded Bytes" "gauge" "$uploadedbytes" "$common_labels"
done
