var height = 315,
    width = 315,
    margin = 10,
    data = [
      {number: "Week 1", rate: 200},
      {number: "Week 2", rate: 150},
      {number: "Week 3", rate: 170},
      {number: "Week 4", rate: 130},
      {number: "Week 5", rate: 350}
    ];

// функция для получения цветов
var color = d3.scale.category10();
// ручное получение цветов
// var color = d3.scale.ordinal()
//     .range(["#ef9a3a", "#50b6ae"]);

// задаем радиус
var radius = Math.min(width - 2 * margin, height- 2 * margin) / 2 - 50; // дописал погрешность уменьшения радиуса

// создаем элемент арки с радиусом
var arc = d3.svg.arc()
  .outerRadius(radius)
  .innerRadius(0);

var toolTip = d3.select(".wrapper")
  .append("div")
  .html('<h2 class="gross-revenue__title">Gross Revenue</h2><span class="gross-revenue__span">0</span>')
  .attr("class", "toolTip gross-revenue");

var value = document.querySelector('.gross-revenue__span');

var pie = d3.layout.pie()
  .sort(null)
  .value(function(d) {
    return d.rate;
  });

var svg = d3.select("#week")
  .attr("class", "axis")
  .attr("width", width)
  .attr("height", height)
  .append("g")
  .attr("transform",
    "translate(" +(width / 2) + "," + (height / 2 ) + ")");

var g = svg.selectAll(".arc")
  .data(pie(data))
  .enter()
  .append("g")
  .attr("class", "arc")
  .style("transform", "scale(1")
  .on("mouseover", function (d) {
    value.textContent = d.value;
    toolTip.style('left', function () {
      return arc.centroid(d)[0] + width / 2 - 65 + 'px';
    });
    toolTip.style('top', function () {
      return arc.centroid(d)[1] + height / 2 - 80 + 'px';
    });
    toolTip.style('opacity', 1);
    d3.select(this)
      .transition()
      .duration(200)
      .style("opacity", .9)
      .style("transform", "scale(1.02")
  })
  .on("mouseout", function () {
    d3.select(this)
      .transition()
      .duration(200)
      .style("transform", "scale(1")
  })

g.append("path")
  .attr("d", arc)
  .style("fill", function(d) {
    return color(d.data.number);
  });

g.append("text")
  .attr("transform", function(d) {
    return "translate(" + arc.centroid(d) + ")";
  })
  .style("text-anchor", "middle")
  .style("font-size", "12px")
  .style("fill", "#fff")
  .style("font-weight", "normal")
  .text(function(d) {
    return d.data.number;
  });
