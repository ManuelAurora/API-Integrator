var data_stack_area = [{
                       "date": "13-Oct-31",
                       "Kermit": 85.44,
                       "piggy": 150,
                       "Gonzo": 80.57,
                       "Lol": 50
                       }, {
                       "date": "13-Nov-30",
                       "Kermit": 130,
                       "piggy": 200.85,
                       "Gonzo": 168.97,
                       "Lol": 150
                       }, {
                       "date": "13-Dec-31",
                       "Kermit": 113.46,
                       "piggy": 350.88,
                       "Gonzo": 40.57,
                       "Lol": 200
                       }, {
                       "date": "14-Jan-30",
                       "Kermit": 140.46,
                       "piggy": 350.88,
                       "Gonzo": 40.57,
                       "Lol": 100
                       }];

function stack_area(w, h, data) {
    var margin = { top: 50, right: 30, bottom: 30, left: 30 };
    var width = w - (margin.left + margin.right);
    var height = h - (margin.top + margin.bottom);
    
    var svg_wraper = d3.select(".chart-wrapper.chart-wrapper_stackArea").attr("style", "width: " + (width + margin.left + margin.right) + "px; height: " + (height + margin.top + margin.bottom) + "px").style("margin", "auto").style("position", "relative");
    
    var svg = d3.select("#chart-stackArea").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("class", "chart__cnt").attr("transform", "translate(" + 50 + "," + margin.top + ")");
    
    // добавляем заголовок
    svg.append("text").attr("x", 0).attr("y", -15).attr("text-anchor", "start").attr("fill", "#ffffff").style("font-size", "1.3em").text("Detroid Sales");
    
    //Зададим цветовую гамму
    var color = d3.scale.ordinal().range(["#f2784b", "#f5a623", "#f9bf3b", "#f9690e", "#f62459"]);
    
    var parseDate = d3.time.format("%y-%b-%d").parse;
    
    var x = d3.time.scale().range([0, width]);
    var y = d3.scale.linear().range([height, 0]);
    
    var xAxis = d3.svg.axis().scale(x).orient("bottom");
    var yAxis = d3.svg.axis().scale(y).orient("left");
    //.tickFormat(formatPercent);
    var svg__axis = svg.append("g").attr("class", "axis").attr("width", width).attr("height", height);
    
    var area = d3.svg.area().x(function (d) {
                               // console.log(x(d.date))
                               
                               return x(d.date);
                               }).y0(function (d) {
                                     // console.log('\n')
                                     // console.log(y(d.y0))
                                     return y(d.y0);
                                     }).y1(function (d) {
                                           // console.log(y(d.y0 + d.y))
                                           return y(d.y0 + d.y);
                                           });
    
    var stack = d3.layout.stack().values(function (d) {
                                         return d.values;
                                         });
    
    color.domain(d3.keys(data[0]).filter(function (key) {
                                         return key !== "date";
                                         }));
    
    data.forEach(function (d) {
                 d.date = parseDate(d.date);
                 });
    
    var plotParams = stack(color.domain().map(function (name) {
                                              return {
                                              name: name,
                                              values: data.map(function (d) {
                                                               // console.log( d[name]*1);
                                                               return {
                                                               date: d.date, y: d[name] * 1
                                                               };
                                                               })
                                              };
                                              }));
    
    plotParams.forEach(function (d, i) {
                       //   console.log( d.values[i])
                       // 	console.log( d.values[i].y );
                       });
    
    // Find the value of the day with highest total value
    var maxDateVal = d3.max(data, function (d) {
                            var vals = d3.keys(d).map(function (key) {
                                                      return key !== "date" ? d[key] : 0;
                                                      });
                            return d3.sum(vals);
                            });
    // Set domains for axes
    x.domain(d3.extent(data, function (d) {
                       return d.date;
                       }));
    
    y.domain([0, maxDateVal]);
    
    var plotArea = svg.selectAll(".plotArea").data(plotParams).enter().append("g").attr("class", "plotArea");
    plotArea.append("path").attr("class", "area").attr("d", function (d) {
                                                       // console.log(d.values);
                                                       return area(d.values);
                                                       }).style("fill", function (d) {
                                                                return color(d.name);
                                                                });
    plotArea.append("text").datum(function (d) {
                                  // console.log( (d) )
                                  return {
                                  name: d.name,
                                  value: d.values[d.values.length - 1]
                                  };
                                  // console.log( (d.value) );
                                  }).attr("transform", function (d) {
                                          // console.log( x(d.value.date) )
                                          return "translate(" + x(d.value.date) + "," + y(d.value.y0 + d.value.y / 2) + ")";
                                          }).attr("x", -60).attr("dy", ".5em").attr('fill', '#ffffff').text(function (d) {
                                                                                                            return d.name;
                                                                                                            });
    
    svg__axis.append("g").attr("class", "axis__x").attr("transform", // сдвиг оси вниз и вправо
                                                        "translate(" + 0 + "," + height + ")").call(xAxis);
    svg__axis.append('g').attr('class', 'axix__y').attr("transform", "translate(" + 0 + "," + 0 + ")").call(yAxis);
    
    // создаем набор вертикальных линий для сетки
    d3.selectAll(".chart-wrapper_stackArea g.axis__x g.tick").append("line") // добавляем линию
    .classed("grid-line", true) // добавляем класс
    .attr("x1", 0).attr("y1", 0).attr("x2", 0).attr("y2", -height);
    
    // рисуем горизонтальные линии
    d3.selectAll(".chart-wrapper_stackArea g.axix__y g.tick").append("line").classed("grid-line", true).attr("x1", 0).attr("y1", 0).attr("x2", width).attr("y2", 0);
}

var stack_area_width = document.querySelector('#chart-stackArea').parentNode.parentNode.clientWidth;
