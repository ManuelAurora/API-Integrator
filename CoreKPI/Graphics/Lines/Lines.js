var svg_wraper = d3.select(".chart-wrapper.chart-wrapper_linechart")
.attr("style", "width: "+(width + margin.left + margin.right)+"px; height: "
      +(height + margin.top + margin.bottom)+"px")
.style("margin", "auto")
.style("position", "relative");

var svg = d3.select("#chart-linechart")
.attr("width", width + margin.left + margin.right)
.attr("height", height + margin.top + margin.bottom)
.append("g")
.attr("class", "chart__cnt")
.attr("transform", "translate(" + 50 + "," + margin.top + ")");

// добавляем заголовок
svg.append("text")
.attr("x", 0)
.attr("y", -15 )
.attr("text-anchor", "start")
.attr("fill", "#ffffff")
.style("font-size", "22px")
.style("font-family", "Arial")
.text("Net Sales / Total Sales");
// Данные для чарта
var usdData = [
               {date: new Date(2016, 12, 22), rate: 26.4},
               {date: new Date(2016, 12, 23), rate: 29.2},
               {date: new Date(2016, 12, 24), rate: 26.4},
               {date: new Date(2016, 12, 25), rate: 26.45},
               {date: new Date(2016, 12, 26), rate: 26.3},
               {date: new Date(2016, 12, 27), rate: 26.87},
               {date: new Date(2016, 12, 28), rate: 26.52}
               ];
var eurData = [
               {date: new Date(2016, 12, 22), rate: 28.2},
               {date: new Date(2016, 12, 23), rate: 28.3},
               {date: new Date(2016, 12, 24), rate: 29.46},
               {date: new Date(2016, 12, 25), rate: 27.95},
               {date: new Date(2016, 12, 26), rate: 27.90},
               {date: new Date(2016, 12, 27), rate: 27.9},
               {date: new Date(2016, 12, 28), rate: 28.5}
               ];

var test = [
            {date: new Date(2016, 12, 22), rate: 27.2},
            {date: new Date(2016, 12, 23), rate: 27.3},
            {date: new Date(2016, 12, 24), rate: 27.46},
            {date: new Date(2016, 12, 25), rate: 29.95},
            {date: new Date(2016, 12, 26), rate: 25.90},
            {date: new Date(2016, 12, 27), rate: 26.9},
            {date: new Date(2016, 12, 28), rate: 24.5}
            ];

// // минимальные значения Y axis
// var minValue = d3.min([
//   d3.min(usdData, function(d){
//     return d.date
//   }),
//   d3.min(eurData, function(d){
//     return d.date
//   })
// ])
// // максимальное значения Y axis
// var maxValue = d3.min([
//   d3.max(usdData, function(d){
//     return d.date
//   }),
//   d3.max(eurData, function(d){
//     return d.date
//   })
// ])

var maxValue = d3.max([
                       d3.max(eurData, function(d) { return d.rate; }),
                       d3.max(usdData, function(d) { return d.rate; }),
                       
                       d3.max(test, function(d) { return d.rate; })
                       ]);

var minValue = d3.min([
                       d3.min(eurData, function(d) { return d.rate; }),
                       d3.min(usdData, function(d) { return d.rate; }),
                       
                       d3.min(test, function(d) { return d.rate; })
                       ]);


// функция интерполяции значений на ось Х
var scaleX = d3.time.scale()
.domain([
         d3.min(usdData, function(d) { return d.date; }),
         d3.max(usdData, function(d) { return d.date; })
         ])
.range([0, width - margin.left]);

// функция интерполяции значений на ось Y
// var scaleY = d3.scale.linear()
//   .domain([maxValue, minValue])
//   .range([0, height]);
var scaleY = d3.scale.linear()
.domain([maxValue+0.5, minValue-0.5])
.range([0, height]);

var xAxis = d3.svg.axis()
.scale(scaleX)
.orient("bottom")
.tickFormat(d3.time.format('%e.%m'));



var yAxis = d3.svg.axis()
.scale(scaleY)
.orient('left')

var svg__axis = svg
.append("g")
.attr("class", "axis")
.attr("width", width)
.attr("height", height);

// отрисовка оси Х
svg__axis.append("g")
.attr("class", "axis__x")
.attr("transform",  // сдвиг оси вниз и вправо
      "translate(" + 0 + "," + height + ")")
.call(xAxis);

svg__axis.append('g')
.attr('class', 'axix__y')
.attr("transform",  // сдвиг оси вниз и вправо
      "translate(" + 0 + "," + 0 + ")")
.call(yAxis)

// создаем набор вертикальных линий для сетки
d3.selectAll("g.axis__x g.tick")
.append("line") // добавляем линию
.classed("grid-line", true) // добавляем класс
.attr("x1", 0)
.attr("y1", 0)
.attr("x2", 0)
.attr("y2", - (height));

// рисуем горизонтальные линии
d3.selectAll("g.axix__y g.tick")
.append("line")
.classed("grid-line", true)
.attr("x1", 0)
.attr("y1", 0)
.attr("x2", width - margin.left)
.attr("y2", 0);


createChart(test, "#2787eb", "test");

createChart(usdData, "#ffb721", "usd");
createChart(eurData, "#6de1b1", "euro");


// обща функция для создания графиков
function createChart (data, colorStroke, label){
    console.log(data)
    var linePath = svg.append('g')
    .attr('class', 'linePath');
    // функция, создающая по массиву точек линии
    var line = d3.svg.line()
    .x(function(d) {
       return scaleX(d.date);
       })
    .y(function(d){
       return scaleY(d.rate);
       })
    .interpolate('linear');
    // .interpolate("cardinal") // a Cardinal spline, with control point duplication on the ends;
    
    var lineCardinal = d3.svg.line()
    .x(function(d){
       return scaleX(d.date);
       })
    .y(function(d){
       return scaleY(d.rate);
       })
    .interpolate('cardinal');
    
    if (label !== "test"){
        var linePath__name = linePath.append("path")
        .attr("d", lineCardinal(data))
        .attr("class", "linePath__"+label+"")
        .style("stroke", colorStroke)
        .style("stroke-width", 2)
        
        // добавляем отметки к точкам
        var circle = linePath.append('g')
        .attr("class", "circle");
        
        circle.selectAll(".dot "+ label)
        .data(data)
        .enter().append("circle")
        .style("stroke", colorStroke)
        .style("stroke-width", 3)
        .style("fill", "white")
        .attr("class", "dot dot__" + label)
        .attr("r", 6)
        .attr("cx", function(d) { return scaleX(d.date); })
        .attr("cy", function(d) { return scaleY(d.rate); })
        
        .on('mouseover', function(d){
            d3.select(this)
            .transition()
            .duration(100)
            .attr("cursor", "pointer")
            .style("stroke", "#ffffff")
            
            d3.select('.tooltip')
            .transition()
            .duration(100)
            .style('top', ''+ ( scaleY(d.rate)) + 'px')
            .style('left', ''+ ( scaleX(d.date)  + 15) + 'px')
            .style('opacity', '1')
            
            d3.select('.tooltip')
            .append("span")
            .attr('class', 'tooltip__text')
            .html(d.rate)
            })
        
        .on('mouseout', function(d){
            d3.select(this)
            .attr("cursor", "default")
            .style("stroke", colorStroke)
            
            d3.select('.tooltip')
            .style('opacity', '0')
            .select('.tooltip__text')
            .remove()
            })
    } else{
        var linePath__name = linePath.append("path")
        .attr("d", line(data))
        .attr("class", "linePath__"+label+"")
        .style("stroke", colorStroke)
        .style("stroke-width", 2)
        .style("stroke-dasharray" , "5,5,5")
    }
};

