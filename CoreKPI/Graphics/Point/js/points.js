// Система отступов для d3

// var width = screen.width - (margin.left + margin.right);
// var height = (screen.height) - (margin.top + margin.bottom);
// if ( (screen.width / 1.2) < screen.height ){
//     var height = (screen.width / 1.2) - (margin.top + margin.bottom);
// } else {
//     var height = (screen.height) - (margin.top + margin.bottom);
// }


var svg_wraper = d3.select(".chart-wrapper")
.attr("style", "width: "+(width + margin.left + margin.right)+"px; height: "
      +(height + margin.top + margin.bottom)+"px")
.style("margin", "auto")
.style("position", "relative");
var svg = d3.select("#chart")
.attr("width", width + margin.left + margin.right)
.attr("height", height + margin.top + margin.bottom)
.append("g")
.attr("class", "chart__cnt")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var pointJson = [
                 {
                 "country": "Algeria",
                 "life": 70.6,
                 "population": 35468208,
                 "gdp": 6300,
                 "color": "blue",
                 "kids": 2.12,
                 "median_age": 26.247
                 },
                 {
                 "country": "Belgium",
                 "life": 80,
                 "population": 10754056,
                 "gdp": 32832,
                 "color": "green",
                 "kids": 1.76,
                 "median_age": 41.301
                 },
                 {
                 "country": "France",
                 "life": 81.3,
                 "population": 63125894,
                 "gdp": 29691,
                 "color": "green",
                 "kids": 1.92,
                 "median_age": 40.112
                 },
                 {
                 "country": "Honduras",
                 "life": 72.9,
                 "population": 7754687,
                 "gdp": 3516,
                 "color": "firebrick",
                 "kids": 2.94,
                 "median_age": 20.945
                 },
                 {
                 "country": "Iran",
                 "life": 73.1,
                 "population": 74798599,
                 "gdp": 12483,
                 "color": "coral",
                 "kids": 1.57,
                 "median_age": 26.799
                 },
                 {
                 "country": "Morocco",
                 "life": 70.2,
                 "population": 32272974,
                 "gdp": 4263,
                 "color": "blue",
                 "kids": 2.12,
                 "median_age": 26.215
                 },
                 {
                 "country": "Russia",
                 "life": 67.6,
                 "population": 142835555,
                 "gdp": 14207,
                 "color": "green",
                 "kids": 1.35,
                 "median_age": 38.054
                 },
                 {
                 "country": "Spain",
                 "life": 81.6,
                 "population": 46454895,
                 "gdp": 26779,
                 "color": "green",
                 "kids": 1.42,
                 "median_age": 40.174
                 },
                 {
                 "country": "USA",
                 "life": 78.5,
                 "population": 313085380,
                 "gdp": 41230,
                 "color": "firebrick",
                 "kids": 2,
                 "median_age": 36.59
                 },
                 {
                 "country": "Australia",
                 "life": 82.1,
                 "population": 22268384,
                 "gdp": 34885,
                 "color": "violet",
                 "kids": 1.9,
                 "median_age": 37.776
                 }
                 ]

console.log(pointJson)

var x = d3.scale.linear()
.domain([0 , d3.max(pointJson, function (d) {
                    console.log('(d.kids) = '+(d.kids))
                    return d.kids;
                    })])
.range([0, width]);
var y = d3.scale.linear()
.domain(d3.extent(pointJson, function (d) {
                  console.log('(d.life) = '+(d.life))
                  return d.life
                  })) //мин и макс продолжительности жизни
.range([(height - 10) , 0]);
var r = d3.scale.linear()
.domain([0, Math.sqrt(d3.max(pointJson, function (d) {
                             return d.population
                             }))]) //мин и макс продолжительности жизни
// .range([0, 20]);
.range([5, 20]);

// добавляем заголовок
svg.append("text")
.attr("x", 0)
.attr("y", -15 )
.attr("text-anchor", "start")
.attr("fill", "#ffffff")
.style("font-size", "22px")
.style("font-family", "Arial")
.text("График значений");

var svg_tooltip = d3.select(".tooltip")
.style("position", "absolute");

// размер осей
var svg__axis = svg
.append("g")
.attr("class", "axis")
.attr("width", width)
.attr("height", height);

// point_wrap
var point_wrap = svg
.append('g')
.attr('class', 'point-wrap')
.attr("width", width)
.attr("height", height)
.attr("transform", "translate(" + 0 + "," + 0 + ")");
// point
var point = point_wrap.selectAll('g.point')
.data(pointJson)
.enter()
.append('g')
.attr('class', 'point')
.style('position', 'relative')

// animation
.on("mouseover", function(d) {
    
    d3.select(this)
    .select('.point__circle')
    .transition()
    .duration(500)
    .attr('fill', '#ffffff')
    .style('cursor', 'pointer');
    
    d3.select(".tooltip")
    .style('opacity', '1')
    .style('padding', '0 5px 0 5px')
    .style('top', ''+ ( y(d.life) + (50) - (r(Math.sqrt(d.population))) - 8 - 36  ) + 'px')
    /*
     where: 50 ==> {
     value margin.top
     }
     where: 36 ==> {
     height tooltip: 36px;
     }
     where: 8 ==> {
     value .tooltip:before border height + 2px;
     }
     */
    .style('left', ''+ ( x(d.kids) - 5 + 10 ) + 'px')
    /*
     where: 5 ==> {
     (padding left + padding right) / 2
     }
     where: 10 ==> {
     changed value with .tooltip: width: 40px;
     }
     */
    .append('span').attr('class', 'tooltip__text')
    .html(Math.ceil(d.population / 1000000) + ' m')
    
    })
.on("mouseout", function(d) {
    d3.select(this)
    .select('.point__circle')
    .transition()
    .duration(500)
    .attr('fill', '#f8bd4f')
    .style('cursor', 'default');
    
    d3.select(".tooltip")
    .style('opacity', '0')
    .style('padding', '0 5px 0 5px')
    .select('.tooltip__text')
    .remove()
    });

// circle
var circle = point.append('circle')
.attr('class', 'point__circle')
.attr('fill', '#f8bd4f')
.attr('cx', function (d){ return x(d.kids); })
.attr('cy', height).transition().duration(1500)
.attr('cy', function (d){ return y(d.life); })
.attr('r', function (d){
      return r(Math.sqrt(d.population)); })
.attr('data-country', function (d) { return d.country });


var axis_top = svg__axis.append('g')
//     .attr('class', 'axis__x axis__x_top')
//     .attr('transform', 'translate(0 ,' + (- 10) +')')
//     .call(
//         d3.svg.axis()
//             .scale(x)
//             .orient('top')
//     );
var axis_bottom = svg__axis.append('g')
.attr('class', 'axis__x axis__x_bottom')
.attr('transform', 'translate(0,' + ( height ) +')')
.call(
      d3.svg.axis()
      .scale(x)
      .orient('bottom')
      );
var axis_left = svg__axis.append('g')
.attr('class', 'axis__y')
.call(
      d3.svg.axis()
      .scale(y)
      .orient('left')
      );

// создаем набор вертикальных линий для сетки
d3.selectAll("g.axis__x g.tick")
.append("line") // добавляем линию
.classed("grid-line", true) // добавляем класс
.attr("x1", 0)
.attr("y1", 0)
.attr("x2", 0)
.attr("y2", - (height));

// рисуем горизонтальные линии
d3.selectAll("g.axis__y g.tick")
.append("line")
.classed("grid-line", true)
.attr("x1", 0)
.attr("y1", 0)
.attr("x2", width)
.attr("y2", 0);



// d3.csv(
//     'data/gapminder-extended.csv',
//     function (country){
//         country.gdp = Number(country.gdp);
//         country.kids = Number(country.kids);
//         country.life = Number(country.life);
//         country.median_age = Number(country.median_age);
//         country.population = Number(country.population);
//         return country;
//     },
//     function (countries){
//         console.log(countries);
//         var x = d3.scale.linear()
//             .domain([0 , d3.max(countries, function (d) {
//                 console.log('(d.kids) = '+(d.kids))
//                 return d.kids;
//             })])
//             .range([0, width]);
//         var y = d3.scale.linear()
//             .domain(d3.extent(countries, function (d) {
//                 console.log('(d.life) = '+(d.life))
//                 return d.life
//             })) //мин и макс продолжительности жизни
//             .range([(height - 10) , 0]);
//         var r = d3.scale.linear()
//             .domain([0, Math.sqrt(d3.max(countries, function (d) {
//                 return d.population
//             }))]) //мин и макс продолжительности жизни
//             // .range([0, 20]);
//             .range([0, 15]);
//
//
//
//         // добавляем заголовок
//         svg.append("text")
//             .attr("x", 0)
//             .attr("y", -15 )
//             .attr("text-anchor", "start")
//             .attr("fill", "#ffffff")
//             .style("font-size", "22px")
//             .style("font-family", "Arial")
//             .text("График значений");
//
//         var svg_tooltip = d3.select(".tooltip")
//             .style("position", "absolute");
//
//         // размер осей
//         var svg__axis = svg
//             .append("g")
//             .attr("class", "axis")
//             .attr("width", width)
//             .attr("height", height);
//         // point_wrap
//         var point_wrap = svg
//             .append('g')
//             .attr('class', 'point-wrap')
//             .attr("width", width)
//             .attr("height", height)
//             .attr("transform", "translate(" + 0 + "," + 0 + ")");
//         // point
//         var point = point_wrap.selectAll('g.point')
//             .data(countries)
//             .enter()
//             .append('g')
//             .attr('class', 'point')
//             .style('position', 'relative')
//
//             // animation
//             .on("mouseover", function(d) {
//
//                 d3.select(this)
//                     .select('.point__circle')
//                     .transition()
//                     .duration(500)
//                     .attr('fill', '#ffffff')
//                     .style('cursor', 'pointer');
//
//                 d3.select(".tooltip")
//                     .style('opacity', '1')
//                     .style('padding', '0 5px 0 5px')
//                     .style('top', ''+ ( y(d.life) + (50) - (r(Math.sqrt(d.population))) - 8 - 36  ) + 'px')
//                     /*
//                         where: 50 ==> {
//                             value margin.top
//                         }
//                         where: 36 ==> {
//                             height tooltip: 36px;
//                         }
//                         where: 8 ==> {
//                             value .tooltip:before border height + 2px;
//                         }
//                     */
//                     .style('left', ''+ ( x(d.kids) - 5 + 10 ) + 'px')
//                     /*
//                         where: 5 ==> {
//                             (padding left + padding right) / 2
//                         }
//                          where: 10 ==> {
//                             changed value with .tooltip: width: 40px;
//                          }
//                     */
//                     .append('span').attr('class', 'tooltip__text')
//                     .html(Math.ceil(d.population / 1000000) + ' m')
//
//             })
//             .on("mouseout", function(d) {
//                 d3.select(this)
//                     .select('.point__circle')
//                     .transition()
//                     .duration(500)
//                     .attr('fill', '#f8bd4f')
//                     .style('cursor', 'default');
//
//                 d3.select(".tooltip")
//                     .style('opacity', '0')
//                     .style('padding', '0 5px 0 5px')
//                     .select('.tooltip__text')
//                     .remove()
//             });
//
//
//
//         // circle
//         var circle = point.append('circle')
//             .attr('class', 'point__circle')
//             .attr('fill', '#f8bd4f')
//             .attr('cx', function (d){ return x(d.kids); })
//             .attr('cy', height).transition().duration(1500)
//             .attr('cy', function (d){ return y(d.life); })
//             .attr('r', function (d){
//                 return r(Math.sqrt(d.population)); })
//             .attr('data-country', function (d) { return d.country });
//
//
//         // var axis_top = svg__axis.append('g')
//         //     .attr('class', 'axis__x axis__x_top')
//         //     .attr('transform', 'translate(0 ,' + (- 10) +')')
//         //     .call(
//         //         d3.svg.axis()
//         //             .scale(x)
//         //             .orient('top')
//         //     );
//         var axis_bottom = svg__axis.append('g')
//             .attr('class', 'axis__x axis__x_bottom')
//             .attr('transform', 'translate(0,' + ( height ) +')')
//             .call(
//                 d3.svg.axis()
//                     .scale(x)
//                     .orient('bottom')
//             );
//         var axis_left = svg__axis.append('g')
//             .attr('class', 'axis__y')
//             .call(
//                 d3.svg.axis()
//                     .scale(y)
//                     .orient('left')
//             );
//
//         // создаем набор вертикальных линий для сетки
//         d3.selectAll("g.axis__x g.tick")
//             .append("line") // добавляем линию
//             .classed("grid-line", true) // добавляем класс
//             .attr("x1", 0)
//             .attr("y1", 0)
//             .attr("x2", 0)
//             .attr("y2", - (height));
//
//         // рисуем горизонтальные линии
//         d3.selectAll("g.axis__y g.tick")
//             .append("line")
//             .classed("grid-line", true)
//             .attr("x1", 0)
//             .attr("y1", 0)
//             .attr("x2", width)
//             .attr("y2", 0);
//     }
// );

