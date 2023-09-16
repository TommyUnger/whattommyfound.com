var color;


d3.select("h1").html("Qumulo Dashboard");

function byte_fmt(n, force_units){
    var pres = ["K", "M", "G", "T", "X"];
    if(force_units){
        return "<span class='num first'>" + (n / Math.pow(1000,pres.indexOf(force_units)+1)).toFixed(3) + "</span><span class='units'>" + force_units + "B</span>";
    }
    for(var i in pres){
        var ii = +i + 1;
        if(n >= Math.pow(1000,ii) && n < Math.pow(1000,ii+1)){
            return "<span class='num first'>" + (n / Math.pow(1000,ii)).toFixed(3) + "</span><span class='units'>" + pres[i] + "B</span>";
        }
    }

}
function get_units(n){
    var pres = ["K", "M", "G", "T", "P"];
    for(var i in pres){
        var ii = +i + 1;
        if(n >= Math.pow(1000,ii) && n < Math.pow(1000,ii+1)){
            return pres[i];
        }
    }
}

function show_activity(act_type, data){
    var ips = {}
    data.forEach(function(d){
        if(!(d.ip in ips)){
            ips[d.ip] = {"iops-write":0, "iops-read": 0
                        , "throughput-write": 0, "throughput-read": 0}
        }
        ips[d.ip][d.type.replace(/(file|metadata)[-]/, '')] += (+d.rate);
    })
    var arr = d3.entries(ips)
    arr.sort(function(a, b){ return b.value[act_type] - a.value[act_type]})
    var short_list = arr.slice(0,7);
    var activity_data = {}
    var ip_list = {}
    short_list.forEach(function(d){
        ip_list[d.key] = d
    })
    data.forEach(function(d){
        var parts = d.path.split("/")
        var key = '/' + (parts.length > 1 ? parts[1] : "")
        if(parts.length > 2){
            key += "/" + parts[2]
        }
        key += ":"
        if(d.ip in ip_list){
            key += d.ip
        }else{
            key += d.ip.split(".").slice(0,3).join(".") + ".*"
        }
        if(d.type.indexOf(act_type) >= 0){
            if(!(key in activity_data)){
                activity_data[key] = 0
            }
            activity_data[key] += d.rate
        }
    });
    act = []
    ips = {}
    paths = {}
    for(var k in activity_data){
        var parts = k.split(":")
        if(activity_data[k] < 100000 && act_type.indexOf("throughput") >= 0){
            continue;
        }
        if(activity_data[k] < 10 && act_type.indexOf("iops") >= 0){
            continue;
        }
        act.push({"path": parts[0], "ip": parts[1], "amount": activity_data[k]});
        if(!(parts[1] in ips)){
            ips[parts[1]] = 0;
        }
        ips[parts[1]] += activity_data[k];
        if(!(parts[0] in paths)){
            paths[parts[0]] = 0;
        }
        paths[parts[0]] += activity_data[k];
    }
    var ip_lookup = {}
    var ips = d3.entries(ips);
    ips.sort(function(a, b){return b.value - a.value});
    ips.forEach(function(d, i){
        ip_lookup[d.key] = i;
    })

    var path_lookup = {}
    var paths = d3.entries(paths);
    paths.sort(function(a, b){return b.value - a.value});
    paths.forEach(function(d, i){
        path_lookup[d.key] = i;
    })

    var t = d3.select("#" + act_type.replace("-", "_") + "_table")
        .append("table")
        .attr("class", "activity inner_border")

    var header_row = t.append("tr")
    header_row.append("th").html("path")
    ips.forEach(function(ip_d){
        header_row.append("th").attr("class", "rotate").append("div").append("span").html(ip_d.key)
    })

    var color = d3.scaleSequential(d3.interpolateMagma)
                    .domain([0, Math.sqrt(1.1*d3.max(d3.entries(activity_data), function(d){ return d.value}))])
    paths.forEach(function(path_d){
        var row = t.append("tr")
        row.append("td").html(path_d.key)
        ips.forEach(function(ip_d){
            var k = path_d.key + ":" + ip_d.key;
            var td = row.append("td").attr("class", "data");
            if(k in activity_data){
                var cc = color(Math.sqrt(activity_data[k]));
                if(act_type.indexOf("throughput") >= 0 && activity_data[k] > 50000){
                    td.html((activity_data[k] / 1000000).toFixed(1));
                    td.style("background-color", cc);
                }else if(act_type.indexOf("iops") >= 0 && activity_data[k] > 1){
                    td.html(Math.round(activity_data[k]).toLocaleString());
                    td.style("background-color", cc);
                }
                if(d3.hsl(cc).l > 0.3){
                    td.style("color", "black");
                }
            }
        })
    })            
}

var grid_size = 8;
var svg = d3.select("#capacity_grid");
var width = svg.attr("width");
var height = svg.attr("height");

var grid = {"x": 37, "y": 21};
grid.area = grid.x * grid.y;
var cap_array = Array(grid.x * grid.y);

svg.style("height", (grid.y * grid_size) + "px");
svg.style("width", (grid.x * grid_size) + "px");
d3.json('/api-capacity', function(d){
    var data_bytes = d.total_size_bytes - d.free_size_bytes - d.snapshot_size_bytes;
    var total_bytes = d.total_size_bytes - d.free_size_bytes;
    var data_blocks = Math.round(grid.area * data_bytes / d.total_size_bytes);
    var snap_blocks = Math.round(grid.area * d.snapshot_size_bytes / d.total_size_bytes);

    var units = get_units(total_bytes);
    /*
    d3.select("#used_cap")
        .html(byte_fmt(total_bytes, units) + 
                " <span class='num second'>" + (100 * total_bytes / d.total_size_bytes).toFixed(1) + '</span><span class="units">%</span>')
    */
    d3.select("#data_cap")
        .html(byte_fmt(data_bytes, units) + 
                " <span class='num second'>" + (100 * data_bytes / d.total_size_bytes).toFixed(1) + '</span><span class="units">%</span>')

    d3.select("#snap_cap")
        .html(byte_fmt(d.snapshot_size_bytes, units) + 
                " <span class='num second'>" + (100 * d.snapshot_size_bytes / d.total_size_bytes).toFixed(1) + '</span><span class="units">%</span>')

    d3.select("#free_cap")
        .html(byte_fmt(d.free_size_bytes, units) + 
                " <span class='num second'>" + (100 * d.free_size_bytes / d.total_size_bytes).toFixed(1) + '</span><span class="units">%</span>')

    svg.selectAll(".square")
        .data(cap_array)
        .enter().append("rect")
        .attr("class", function(d, i){
            return "square " + (i < data_blocks?"data":(i < data_blocks + snap_blocks?"snap":""));
        })
        .attr("width", function(d) { return grid_size-2; })
        .attr("height", function(d) { return grid_size-2; })
        .attr("x", function(d, i){
            return Math.floor(i / grid.y) * (grid_size);
        })
        .attr("y", function(d, i){
            return (i % grid.y) * (grid_size);
        })
});

d3.json('/api-activity', function(data){
    show_activity("throughput-read", data)
    show_activity("throughput-write", data)
    show_activity("iops-read", data)
    show_activity("iops-write", data)

    var client_data = d3.nest()
                        .key(function(d){ return d.ip })
                        .rollup(function(v) { return {
                                    count: v.length,
                                    write_iops: d3.sum(v.filter(d => d.type.indexOf("iops-write") >= 0), function(d) { return d.rate; }),
                                    read_iops: d3.sum(v.filter(d => d.type.indexOf("iops-read") >= 0), function(d) { return d.rate; }),
                                    write_throughput: d3.sum(v.filter(d => d.type.indexOf("throughput-write") >= 0), function(d) { return d.rate; }),
                                    read_throughput: d3.sum(v.filter(d => d.type.indexOf("throughput-read") >= 0), function(d) { return d.rate; }),
                                  };
                                })
                        .entries(data);
    ["read_iops", "write_iops", "read_throughput", "write_throughput"].forEach(function(dt){
        client_data.sort(function(a, b){ return b.value[dt] - a.value[dt]});
        d3.select("#" + dt)
            .html(client_data[0].key + " &nbsp; " + (dt.indexOf("iops")>=0?client_data[0].value[dt].toFixed(0) + "<span class='units'>IOPS</span>":(client_data[0].value[dt]/1000000).toFixed(2) + "<span class='units'>MB/s</span>"))
    })
    d3.select("#client_count").html(client_data.length);

});

d3.json('/api-capacity-tree-change', function(data){
    var paths = {};
    data[0].files.forEach(function(d){
        paths['/' + d.name] = {"0": +d.capacity_usage, "1": 0};
    });

    data[1].largest_paths.forEach(function(d){
        var parts = d.path.split("/");
        the_dir = "/" + parts[1]
        if(!(the_dir in paths)){
            paths[the_dir] = {"0": 0, "1": 0};
        }
        paths[the_dir]["1"] += (+d.capacity_used);
    });

    var path_arr = [];
    for(var p in paths){
        path_arr.push({"path": p
                        , "cap0": paths[p]["0"]
                        , "cap1": paths[p]["1"]
                        , "diff": paths[p]["0"] - paths[p]["1"]
                    })
    }
    path_arr.sort(function(a, b){ return Math.abs(b.diff) - Math.abs(a.diff)})
    var uu = get_units(Math.abs(path_arr[0].diff));
    path_arr.slice(0,9).forEach(function(d){
        if(d.path != "/"){
            d3.select(".cap_change")
                .append("div")
                .html("<span style='width:90px; text-align: right; display:inline-block;'>" 
                        + (d.diff>0?"+":"-") + byte_fmt(Math.abs(d.diff), uu) + "</span>&nbsp; " + d.path)
        }
    })
});




d3.csv('/api-capacity-tree', function(error, data){
    var svg = d3.select("svg.cap_tree"),
        width = (window.innerWidth-36),
        height = +svg.attr("height");
    svg.style("width", (window.innerWidth-36) + 'px')
    var format = d3.format(",d");

    var color = d3.scaleSequential(d3.interpolateGreys)
                    .domain([8, -4]);

    var stratify = d3.stratify()
        .parentId(function(d) { return d.id.substring(0, d.id.lastIndexOf("/")); });

    var treemap = d3.treemap()
            .size([width, height])
            .paddingOuter(3)
            .paddingTop(19)
            .paddingInner(1)
            .round(true);

    var root = stratify(data)
      .sum(function(d) { return d.value; })
      .sort(function(a, b) { return b.height - a.height || b.value - a.value; });

    treemap(root);

      var cell = svg
        .selectAll(".node")
        .data(root.descendants())
        .enter().append("g")
          .attr("transform", function(d) { return "translate(" + d.x0 + "," + d.y0 + ")"; })
          .attr("class", "node")
          .each(function(d) { d.node = this; })
          .on("mouseover", hovered(true))
          .on("mouseout", hovered(false));

      cell.append("rect")
          .attr("id", function(d) { return "rect-" + d.id; })
          .attr("width", function(d) { return d.x1 - d.x0; })
          .attr("height", function(d) { return d.y1 - d.y0; })
          .style("fill", function(d) { return color(d.depth); });

      cell.append("clipPath")
          .attr("id", function(d) { return "clip-" + d.id; })
        .append("use")
          .attr("xlink:href", function(d) { return "#rect-" + d.id + ""; });

      var label = cell.append("text")
          .attr("clip-path", function(d) { return "url(#clip-" + d.id + ")"; });

      label
        .filter(function(d) { return d.children; })
        .selectAll("tspan")
          .data(function(d) { 
                return d.id.substring(d.id.lastIndexOf("/") + 1).split(/(?=[A-Z][^A-Z])/g).concat("\xa0" 
                    + (d.value / Math.pow(1000, 4)).toFixed(1) + "TB"); 
            })
        .enter().append("tspan")
          .attr("x", function(d, i) { return i ? null : 4; })
          .attr("y", 13)
          .text(function(d) { return d; });

      label
        .filter(function(d) { return !d.children; })
        .selectAll("tspan")
          .data(function(d) { 
            return d.id.substring(d.id.lastIndexOf("/") + 1).split(/(?=[A-Z][^A-Z])/g).concat( (d.value / Math.pow(1000, 4)).toFixed(1) + "TB" ); 
        })
        .enter().append("tspan")
          .attr("x", 4)
          .attr("y", function(d, i) { return 13 + i * 10; })
          .text(function(d) { return d; });

      cell.append("title")
          .text(function(d) { return d.id + "\n" + format(d.value); });
    });

    function hovered(hover) {
      return function(d) {
        d3.selectAll(d.ancestors().map(function(d) { return d.node; }))
            .classed("node--hover", hover)
          .select("rect")
            .attr("width", function(d) { return d.x1 - d.x0 - hover; })
            .attr("height", function(d) { return d.y1 - d.y0 - hover; });
      };
    }


var last_vals = null;
var diff_vals = [];
var tput_svg = d3.select("#throughput");
var tput_x = d3.scaleLinear().range([15, tput_svg.attr("width")-20]);
var tput_y = d3.scaleLinear().range([-10, tput_svg.attr("height")-40]);
var last_max_tput = null;

function show_throughput(){
    d3.json('/api-list-network-status', function(data){
        var height = tput_svg.attr("height") - 20;
        var width = tput_svg.attr("width") - 25;
        data.sort(function(a, b){return (+a.node_id) - (+b.node_id)})
        var cur_vals = [];
        data.forEach(function(d){
            cur_val = {"node_id": +d.node_id, 
                        "ts": +d.interface_details.timestamp, 
                        "rx": (+d.interface_details.bytes_received), 
                        "tx": (+d.interface_details.bytes_sent), 
                        };
            cur_vals.push(cur_val);
        });
        if(last_vals){
            diff_vals.forEach(function(d){
                d.iter += 1;
            })
            cur_vals.forEach(function(d, i){
                var diff_val = {
                    "node_id": d.node_id,
                    "ts": last_vals[i].ts,
                    "rx": Math.round(8 * 1000 * (d.rx - last_vals[i].rx) / (d.ts - last_vals[i].ts)),
                    "tx": Math.round(8 * 1000 * (d.tx - last_vals[i].tx) / (d.ts - last_vals[i].ts)),
                    "iter": 0,
                }
                diff_vals.push(diff_val)
            })
        }else{
            tput_y.domain([0, cur_vals.length])
            tput_svg.append("g")           
                  .attr("class", "grid y")
                  .attr("transform", "translate(14, 0)")
                  .call(d3.axisLeft(tput_y)
                        .tickSize(0)
                        .ticks(cur_vals.length)
                        .tickFormat(function(d, i) {
                            if(d > 0){
                                return d;
                            }
                        })
                  )
        }
        last_vals = cur_vals;
        diff_vals = diff_vals.filter(function(d) { return d.iter <= 20 })

        if(diff_vals.length > 0){
            var max_tput = 1.1 * d3.max(diff_vals, function(d){return Math.max(d.rx, d.tx)});
            if(max_tput < Math.pow(10, 9)){
                max_tput = Math.pow(10, 9);
            }else if(max_tput < Math.pow(10, 10)){
                max_tput = Math.pow(10, 10);
            }else if(max_tput < 4*Math.pow(10, 10)){
                max_tput = 4*Math.pow(10, 10);
            }else{
                max_tput = Math.pow(10, 11);
            }
            tput_x.domain([0, max_tput]);


            if(last_max_tput != max_tput){
                tput_svg.selectAll(".grid.x").remove();
                tput_svg.append("g")           
                      .attr("class", "grid x")
                      .attr("transform", "translate(0," + height + ")")
                      .call(d3.axisBottom(tput_x)
                            .ticks(5)
                            .tickSize(-height)
                            .tickFormat(function(d, i) {
                                var dd = (d / Math.pow(1000, 3));
                                if(dd == 0){
                                    return 0;
                                }else if(dd < 1){
                                    return dd.toFixed(1);
                                }else{
                                    return dd.toFixed(0) + "gbit";
                                }
                            })
                      )
            }


            last_max_tput = max_tput;
            var circlerx = tput_svg
                                .selectAll("circle.rx")
                                .data(diff_vals.slice());
            circlerx.exit().remove();
            circlerx.enter().append("circle")
                .attr("class", function(d){return get_iter_class("rx", d.iter)})
                .attr("r",1.5)
                .attr("cy", function(d){return tput_y(d.node_id)-2;})
                .attr("cx",function(d){return tput_x(d.rx);})
            circlerx
                .attr("class", function(d){return get_iter_class("rx", d.iter)})
                .attr("cy", function(d){return tput_y(d.node_id)-2;})
                .attr("cx",function(d){return tput_x(d.rx);})

            var circletx = tput_svg
                                .selectAll("circle.tx")
                                .data(diff_vals.slice());
            circletx.exit().remove();
            circletx.enter().append("circle")
                .attr("class", function(d){return get_iter_class("tx", d.iter)})
                .attr("r",1.5)
                .attr("cy", function(d){return tput_y(d.node_id)+2;})
                .attr("cx",function(d){return tput_x(d.tx);})
            circletx
                .attr("class", function(d){return get_iter_class("tx", d.iter)})
                .attr("cy", function(d){return tput_y(d.node_id)+2;})
                .attr("cx",function(d){return tput_x(d.tx);})


        }else{


        }
        setTimeout(show_throughput, 2000);
    })
}

var pc = null;
var keep_counters = {'fs:statistics:write_op': 1
                     , 'fs:statistics:bytes_written': 1
                     , 'fs:statistics:read_op': 1
                     , 'fs:statistics:bytes_read': 1

                     , 'fs:prefetcher:contiguous_policy_mispredicted': 1
                     , 'fs:prefetcher:contiguous_policy_not_prefetchable_when_asked': 1
                     , 'fs:prefetcher:contiguous_policy_prefetch_success': 1
                     , 'fs:prefetcher:contiguous_policy_prefetch_waste': 1
                     , 'fs:prefetcher:contiguous_policy_prefetched': 1
                     , 'fs:prefetcher:contiguous_policy_read_not_predicted': 1
                     , 'fs:prefetcher:contiguous_policy_successfully_predicted': 1
                     , 'fs:prefetcher:contiguous_policy_wasted_lookups': 1
                     , 'fs:prefetcher:dropped_prefetches': 1
                     , 'fs:prefetcher:next_file_confirmed': 1
                     , 'fs:prefetcher:pattern_not_found': 1

                     , 'fs:data_block:read_hdd_disk_cache_hits': 1
                     , 'fs:data_block:read_hdd_disk_cache_misses': 1
                     , 'fs:data_block:read_hdd_disk_cache_waits': 1
                     , 'fs:data_block:read_ssd_disk_cache_hits': 1
                     , 'fs:data_block:read_ssd_disk_cache_misses': 1
                     , 'fs:data_block:read_ssd_disk_cache_waits': 1
                     , 'fs:data_block:read_trans_cache_hits': 1
                     , 'fs:data_block:read_trans_cache_misses': 1
                     , 'protocols:nfs:nfs3:nfs3_ops:bytes_read': 1
                     , 'protocols:nfs:nfs3:nfs3_ops:bytes_written': 1
                     , 'replication:replicator:replication_file_bytes_transferred': 1
                     , 'smb2:disk_file:bytes_read': 1
                     , 'smb2:disk_file:bytes_written': 1
                     , 'fs:statistics:deferred_bytes_deleted': 1
                     , 'fs:statistics:snapshot_bytes_deleted': 1

                    , 'execute_latency_bucket_usec_0': 1
                    , 'execute_latency_bucket_usec_128': 1
                    , 'execute_latency_bucket_usec_256': 1
                    , 'execute_latency_bucket_usec_512': 1
                    , 'execute_latency_bucket_usec_1024': 1
                    , 'execute_latency_bucket_usec_2048': 1
                    , 'execute_latency_bucket_usec_4096': 1
                    , 'execute_latency_bucket_usec_8192': 1
                    , 'execute_latency_bucket_usec_16384': 1
                    , 'execute_latency_bucket_usec_32768': 1
                    , 'execute_latency_bucket_usec_65536': 1
                    , 'execute_latency_bucket_usec_131072': 1
                    , 'execute_latency_bucket_usec_262144': 1
                    , 'execute_latency_bucket_usec_524288': 1
                    , 'execute_latency_bucket_usec_1048576': 1
                    , 'execute_latency_bucket_usec_2097152': 1
                    , 'execute_latency_bucket_usec_4194304': 1
                    , 'execute_latency_bucket_usec_8388608': 1
                    , 'execute_latency_bucket_usec_16777216': 1
                    , 'execute_latency_bucket_usec_33554432': 1
                    , 'execute_latency_bucket_usec_67108864': 1
                    };

var values_last = null;
var counter_hist = [];

var rsize_data = {};
var wsize_data = {};
var s = 2048;
while(s <= 1024*1024){
    rsize_data[s] = 0;
    wsize_data[s] = 0;
    s *= 2;
}

function add_size(arr, in_sz){
    for(var sz in arr){
        if((+sz) > in_sz){
            arr[sz] += 1;
            return
        }
    }
}


var cache_table = d3.select(".cache").append("table");
var header_row = cache_table.append("thead").append("tr");
header_row.append("th").html("Location");
header_row.append("th").html("5 sec");
header_row.append("th").html("1 min");
header_row.append("th").html("5 min");
var cache_data_table = cache_table.append("tbody");
var cache_data_status = null;
var pc_vals = null;
var vals_hist = [];


var sizes_width = 200;
var sizes_height = 175;
var sizes_y = d3.scaleBand()
                .range([sizes_height, 0]);

function graph_sizes(name, data){
    var clean_data = d3.entries(data);
    sizes_y.domain(Object.keys(data));
    var sizes_total = d3.sum(clean_data, function(d){ return d.value});
    var sizes_x = d3.scaleLinear()
                .range([50, sizes_width])
                .domain([0, d3.max(clean_data, function(d){return d.value})])
    var chart = d3.select("." + name + " svg")
    if(chart.empty()){
        chart = d3.select("." + name)
                  .append("svg")
                  .attr("width", sizes_width)
                  .attr("height", sizes_height)
        chart.append("g")
            .attr("class",  "y axis")
            .attr("transform", "translate(55, 0)");

    }

    var bars = chart.selectAll(".bar")
        .remove()
        .exit()
        .data(clean_data)
      .enter().append("rect")
        .attr("class", "bar")
        .attr("x", sizes_x(0))
        .attr("height", sizes_y.bandwidth()-2)
        .attr("y", function(d) { return sizes_y(d.key); })
        .attr("width", function(d) { return sizes_x(d.value) - sizes_x(0); })
        .attr("fill", function(d, i){
            return d3.schemeRdYlGn[clean_data.length][i];
        })

    var bars = chart.selectAll(".bar_label")
        .remove()
        .exit()
        .data(clean_data)
      .enter().append("text")
            .attr("class", "bar_label")
            .attr("y", function(d) { return sizes_y.bandwidth() + sizes_y(d.key) - 6})
            .attr("x", function(d) { return sizes_x(d.value) + (d.value / sizes_total > 0.12?-1:1)})
            .attr("text-anchor", function(d){ return (d.value / sizes_total > 0.12?"end":"begin")})
            .attr("fill", function(d){ return (d.value / sizes_total > 0.12?"black":"#ddd")})
            .text(function(d){ if(d.value  > 0){return Math.round(100 * d.value / sizes_total) + "%"}})

    chart.select(".y.axis")
        .call(d3.axisLeft(sizes_y).tickFormat(d3.format(",")));

}


//set up chart
var prefetch_margin = {top: 5, right: 0, bottom: 5, left: 75};
var prefetch_width = 380;
var prefetch_height = 165;
var prefetch_chart = d3.select(".prefetch svg")
                .attr("width", prefetch_width + prefetch_margin.left + prefetch_margin.right)
                .attr("height", prefetch_height + prefetch_margin.top + prefetch_margin.bottom)
                .append("g")
                .attr("transform", "translate(" + prefetch_margin.left + "," + prefetch_margin.top + ")");
var prefetch_x = d3.scaleLinear()
                .range([0, prefetch_width]);
var prefetch_y = d3.scaleLinear()
                .range([prefetch_height, 0]);
var prefetch_xAxis = d3.axisBottom(prefetch_x);
var prefetch_yAxis = d3.axisLeft(prefetch_y);

var prefetch_line = d3.line()
    .x(function(d, i) { return prefetch_x(i); })
    .y(function(d) { return prefetch_y(d.bytes_read_per_sec); })

var prefetch_area = d3.area()
    .x(function(d, i) { return prefetch_x(i); })
    .y0(function(d){ return prefetch_y(0); })
    .y1(function(d) { return prefetch_y(d.bytes_read_per_sec); });


function  prefetch_y_gridlines() {       
    return d3.axisLeft(prefetch_y)
        .ticks(6)
}

function prefetch_update(data){
    data.forEach(function(d){
        d.bytes_read_per_sec = d.bytes_read / 5;
        d.bytes_read_with_prefetch_per_sec = d.bytes_read_with_prefetch / 5;
        d.bytes_wasted_prefetch_per_sec = d.bytes_wasted_prefetch / 5;
    })
    var bar_count = 60;
    prefetch_x.domain( [0, bar_count] );
    var y_domain = [-d3.max(data, function(d){ return d.bytes_wasted_prefetch_per_sec; }), 
                         d3.max(data, function(d){ return d.bytes_read_per_sec; })];
    prefetch_y.domain( y_domain );
    var barWidth = prefetch_width / bar_count;

    var success_bars = prefetch_chart.selectAll(".success_bar")
                            .remove()
                            .exit()
                            .data(data);

    var waste_bars = prefetch_chart.selectAll(".waste_bar")
                            .remove()
                            .exit()
                            .data(data);

    var prefetch_linegraph = prefetch_chart.select("path.read_throughput")
    var prefetch_areagraph = prefetch_chart.select("path.read_throughput_area")

    if ( prefetch_linegraph.empty() ) {

        prefetch_chart.append("g")
          .attr("class", "grid y")
          .call(prefetch_y_gridlines()
                    .tickSize(-prefetch_width)
                    .tickFormat("")
                )
        prefetch_chart.append("g")
            .attr("class", "y ticks")
            .call(prefetch_y_gridlines());

         prefetch_linegraph = prefetch_chart.append('path')
                          .attr("class", "line read_throughput")
         prefetch_areagraph = prefetch_chart.append('path')
                          .attr("class", "line read_throughput_area")
                          .style("stroke", "transparent");
    }

    prefetch_chart.select(".y.grid")
            .transition()
            .call(prefetch_y_gridlines()
                    .tickSize(-prefetch_width)
                    .tickFormat(""));

    prefetch_chart.select(".y.ticks")
            .transition()
            .call(prefetch_y_gridlines());


    prefetch_linegraph
            .transition()
            .duration(1)
            .attr('d', prefetch_line(data));
    prefetch_chart.append("path")
      .data(data)
      .attr("class", "line")
      .attr("d", prefetch_line);

    prefetch_areagraph
            .transition()
            .duration(1)
            .attr('d', prefetch_area(data));
    prefetch_chart.append("path")
      .data(data)
      .attr("class", "area")
      .attr("d", prefetch_area);

    success_bars.enter()
        .append("rect")
        .attr("class", "success_bar")
        .attr("x", function(d, i){ return i * barWidth + 1 - barWidth / 2 })
        .attr("y", function(d){ return prefetch_y( d.bytes_read_with_prefetch_per_sec); })
        .attr("height", function(d){ return prefetch_y( 0 ) - prefetch_y( d.bytes_read_with_prefetch_per_sec); })
        .attr("width", barWidth * 0.7)
        .attr("fill", function(d){ 
            return "rgba(100, 200, 100, 0.9)";
        });

    waste_bars.enter()
        .append("rect")
        .attr("class", "waste_bar")
        .attr("x", function(d, i){ return i * barWidth + 1 - barWidth / 2 })
        .attr("y", function(d){ return prefetch_y( 0 ); })
        .attr("height", function(d){ return prefetch_y(-d.bytes_wasted_prefetch_per_sec) - prefetch_y( 0 ); })
        .attr("width", barWidth * 0.7)
        .attr("fill", function(d){ 
            return  "red";
        });

            
}//end update



function get_perf_counters(){
    var values_current = {}
    d3.json('/api-perf-counters', function(data){
        for(var node_id in data){
            data[node_id].forEach(function(counters){
                var fields = counters['fields'];
                for(var k in fields){
                    if(k in keep_counters){
                        if(!(k in values_current)){
                            values_current[k] = 0;
                        }
                        values_current[k] += (+fields[k]);
                    }
                }
            })
        }



        if(values_last){
            if(vals_hist.length >= 60){
                vals_hist.pop();
            }
            var new_vals = {}
            for(var k in keep_counters){
                new_vals[k] = (values_current[k] - values_last[k]);
            }
            new_vals['read_size'] = new_vals['fs:statistics:bytes_read'] / new_vals['fs:statistics:read_op'];
            new_vals['write_size'] = new_vals['fs:statistics:bytes_written'] / new_vals['fs:statistics:write_op'];
            new_vals['bytes_read_from_ram'] = new_vals['fs:data_block:read_trans_cache_hits'] * 4096;
            new_vals['bytes_read_from_ssd'] = new_vals['fs:data_block:read_ssd_disk_cache_hits'] * 4096;
            new_vals['bytes_read_from_hdd'] = new_vals['fs:statistics:bytes_read'] - (new_vals['bytes_read_from_ram'] + new_vals['bytes_read_from_ssd'])
            if(new_vals['bytes_read_from_hdd'] < 0){
                new_vals['bytes_read_from_hdd'] = 0;
            }
            new_vals['bytes_read'] = new_vals['bytes_read_from_ram'] + new_vals['bytes_read_from_ssd'] + new_vals['bytes_read_from_hdd'];
            new_vals['percent_read_from_ram'] = new_vals['bytes_read_from_ram'] / new_vals['bytes_read']
            new_vals['percent_read_from_ssd'] = new_vals['bytes_read_from_ssd'] / new_vals['bytes_read']
            new_vals['percent_read_from_hdd'] = new_vals['bytes_read_from_hdd'] / new_vals['bytes_read']
            new_vals['bytes_read_with_prefetch'] = new_vals['fs:prefetcher:contiguous_policy_prefetch_success']
            new_vals['bytes_wasted_prefetch'] = new_vals['fs:prefetcher:contiguous_policy_prefetch_waste']

            var rsize = new_vals['read_size'];
            var wsize = new_vals['write_size'];
            add_size(rsize_data, rsize);
            add_size(wsize_data, wsize);

            graph_sizes("read_size", rsize_data);
            graph_sizes("write_size", wsize_data);
            pc_vals = JSON.parse(JSON.stringify(new_vals));
            vals_hist.unshift(JSON.parse(JSON.stringify(new_vals)));

            var pivoted = []
            vals_hist.forEach(function(d, i){
                Object.keys(d).forEach(function(k){
                    pivoted.push({"i": i, "type": k, "val": d[k]});
                })
            })

            var new_d = d3.nest()
              .key(function(d) { return d.type; })
              .rollup(function(v) { return {
                    "5_sec":{
                        avg: d3.mean(v.filter(function(d){return d.i <= 1}), function(d) { return d.val; }),
                        count: v.filter(function(d){return d.i <= 0}).length,
                    },
                    "1_min":{
                        avg: d3.mean(v.filter(function(d){return d.i <= 12}), function(d) { return d.val; }),
                        count: v.filter(function(d){return d.i <= 12}).length,
                    },
                    "5_min":{
                        avg: d3.mean(v.filter(function(d){return d.i <= 60}), function(d) { return d.val; }),
                        count: v.filter(function(d){return d.i <= 60}).length,
                    },

                    }; 
                })
              .entries(pivoted)

            var filtered_data = new_d.filter(function(d){return /^percent/.test(d.key)});

            if(!cache_data_status){
                var cache_data_rows = cache_data_table.selectAll("tr")
                    .data(filtered_data)
                    .enter()
                        .append("tr")
                        .attr("class", function(d){return "type_" + d.key.replace("percent_read_from_", "")})
                        .selectAll('td')
                          .data(function (row) {
                            var new_row = [row.key.replace("percent_read_from_", "").toUpperCase()]
                            new_row.push({"val": row.value["5_sec"].avg, "type": row.key.replace("percent_read_from_", "")})
                            new_row.push({"val": row.value["1_min"].avg, "type": row.key.replace("percent_read_from_", "")})
                            new_row.push({"val": row.value["5_min"].avg, "type": row.key.replace("percent_read_from_", "")})
                            return new_row;
                          })
                    .enter()
                    .append('td')
                    .attr("class", function(d){return "cash ";})
                    .html(function (d, i) {
                            if(i ==0){
                                return d;
                            }else{
                                var html = ""
                                if(d.val < 0.01){
                                    html += (d.val*100).toFixed(1) + "%";
                                }else{
                                    html += (d.val*100).toFixed(0) + "%";                                
                                }
                                html += "<div style='width: " + Math.round(d.val * 100) + "px'></div>";
                                return html;
                            }
                        });
                cache_data_status = true;
            }else{
                var cache_data_rows = cache_data_table.selectAll("tr")
                    .data(filtered_data);

                cache_data_rows.enter()
                        .append("tr")
                        .attr("class", function(d){return "type_" + d.key.replace("percent_read_from_", "")});

                var cache_data_cells = cache_data_rows.selectAll('td')
                          .data(function (row) {
                            var new_row = [row.key.replace("percent_read_from_", "").toUpperCase()]
                            new_row.push({"val": row.value["5_sec"].avg, "type": row.key.replace("percent_read_from_", "")})
                            new_row.push({"val": row.value["1_min"].avg, "type": row.key.replace("percent_read_from_", "")})
                            new_row.push({"val": row.value["5_min"].avg, "type": row.key.replace("percent_read_from_", "")})
                            return new_row;
                          });
                        
                cache_data_cells.enter()
                    .append('td')
                    .attr("class", function(d){return "cash ";});

                cache_data_cells
                        .html(function (d, i) {
                            if(i ==0){
                                return d;
                            }else{
                                var html = ""
                                if(d.val < 0.01){
                                    html += (d.val*100).toFixed(1) + "%";
                                }else{
                                    html += (d.val*100).toFixed(0) + "%";                                
                                }
                                html += "<div style='width: " + Math.round(d.val * 100) + "px'></div>";
                                return html;
                            }
                        });
            }
            prefetch_update(vals_hist);
        } // values_last
        values_last = JSON.parse(JSON.stringify(values_current));
        setTimeout(get_perf_counters, 2500);
    })
}
get_perf_counters();



/******/
function capacity_hist(){
    d3.json('/api-capacity-history', function(data){
        var margin = {top: 5, right: 30, bottom: 18, left: 40},
            width = 460 - margin.left - margin.right,
            height = 174 - margin.top - margin.bottom;

        var svg = d3.select(".cap_trend svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform",
                  "translate(" + margin.left + "," + margin.top + ")");

        data.forEach(function(d){
            d.capacity_used = +d.capacity_used + (+d.metadata_used);
            d.capacity_used_snaps = +d.snapshot_used;
            d.capacity_total = d.capacity_used + d.capacity_used_snaps;
            d.time = moment(d.period_start_time*1000).toDate()
        })

        var cap_headers = ['capacity_used', 'capacity_used_snaps'];

        var x = d3.scaleTime()
            .domain(d3.extent(data, function(d) { return d.time; }))
            .range([ 0, width ]);
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x).ticks(5));

        // Add Y axis
        var max_y = d3.max(data, function(d){return d.capacity_total;});
        var y = d3.scaleLinear()
            .domain([0, max_y])
            .range([ height, 0 ]);
        svg.append("g")
            .call(d3.axisLeft(y).ticks(5).tickFormat(bytesToString));

        var color = d3.scaleOrdinal()
            .domain(cap_headers)
            .range(['#abf','#eb5'])

        //stack the data?
        var stackedData = d3.stack()
            .keys(cap_headers)(data)

        svg.append("g")         
              .attr("class", "grid")
              .call(d3.axisLeft(y)
                      .ticks(5)
                      .tickSize(-width)
                      .tickFormat("")
              )

        svg
            .selectAll("mylayers")
            .data(stackedData)
            .enter()
            .append("path")
              .style("fill", function(d) { return color(d.key); })
              .style("opacity", 0.6)
              .attr("d", d3.area()
                .x(function(d, i) { return x(d.data.time); })
                .y0(function(d) { return y(d[0]); })
                .y1(function(d) { return y(d[1]); })
            )

        svg
            .selectAll("linelayers")
            .data(stackedData)
            .enter()
            .append("path")
              .style("stroke", function(d) { return color(d.key); })
              .style("fill", "transparent")
              .attr("d", d3.line()
                .x(function(d, i) { return x(d.data.time); })
                .y(function(d) { return y(d[1]); })
            )


    });
}


var bytesToString = function (bytes) {
    var fmt = d3.format('.0f');
    var us = [{"u":0, "p": ""}
            , {"u":1, "p":"K"}
            , {"u":2, "p":"M"}
            , {"u":3, "p":"G"}
            , {"u":4, "p":"T"}
            , {"u":5, "p":"P"}
            ]
    var val = ""
    for(var i=0; i<us.length; i++){
        d = us[i];
        if(bytes < Math.pow(1000, d.u+1)){
            return fmt(bytes / Math.pow(1000, d.u)) + d.p + 'B';
        }
    }
}



function get_iter_class(typ, iter){
    var iter_class = iter_class = "iter" + iter;
    if(iter > 10){
        iter_class = "older"
    }else if(iter > 2){
        iter_class = "old"
    }
    return typ + " " + iter_class;
}

show_throughput();
capacity_hist();
