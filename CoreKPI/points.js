"use strict";

// const data_point = [
//     {
//         "value": 70.6,
//         "date": new Date(2017, 1, 1)
//     },
//     {
//         "value": 80,
//         "date": new Date(2017, 2, 1)
//     },
//     {
//         "value": 81.3,
//         "date": new Date(2017, 3, 1)
//     }
// ];


function draw(data) {
    var w = document.body.clientWidth;
    var h = document.body.clientHeight;
    var margin = { top: 50, right: 30, bottom: 30, left: 30 };
    var width = w - margin.left - margin.right;
    var height = h - margin.top - margin.bottom;
    var RADIUS = 10;

    var svg_wraper = d3.select('.chart-wrapper.chart-wrapper_points').attr("style", "width: " + (width + margin.left + margin.right) + "px; height: " + (height + margin.top + margin.bottom) + "px").style("margin", "auto").style("position", "relative");

    var svg = d3.select("#chart-points").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("class", "chart__cnt").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var pointJson = data;

    // let x = d3.scale.linear()
    //     .domain([0 , d3.max(pointJson, function (d) {
    //         return d.date;
    //     })])
    //     .range([0, width]);
    var x = d3.time.scale().rangeRound([0, width]);

    x.domain(d3.extent(data, function (d) {
        return d.date;
    }));

    var y = d3.scale.linear().domain(d3.extent(pointJson, function (d) {
        return d.value;
    })).range([height - 10, 0]);
    var r = d3.scale.linear().domain([0, Math.sqrt(d3.max(pointJson, function (d) {
        return d.date;
    }))]).range([2, 20]);

    // добавляем заголовок
    svg.append("text").attr("x", 0).attr("y", -15).attr("text-anchor", "start").attr("fill", "#ffffff").style("font-size", "22px");
    // .text("График значений");

    var svg_tooltip = d3.select(".tooltip").style("position", "absolute");

    // размер осей
    var svg__axis = svg.append("g").attr("class", "axis").attr("width", width).attr("height", height);

    // point_wrap
    var point_wrap = svg.append('g').attr('class', 'point-wrap').attr("width", width).attr("height", height).attr("transform", "translate(" + 0 + "," + 0 + ")");
    // point
    var point = point_wrap.selectAll('g.point').data(pointJson).enter().append('g').attr('class', 'point').style('position', 'relative')

    // animation
    .on("mouseover", function (d) {

        d3.select(this).select('.point__circle').transition().duration(500).attr('fill', '#ffffff').style('cursor', 'pointer');

        d3.select(".chart-wrapper_points .tooltip").style('opacity', '1').style('padding', '0 5px 0 5px').style('top', '' + (y(d.value) + 45 - r(Math.sqrt(d.value)) - 8 - 36) + 'px').style('left', '' + (x(d.date) - 5 + 14) + 'px').append('span').attr('class', 'tooltip__text').html(d.value);
    }).on("mouseout", function (d) {
        d3.select(this).select('.point__circle').transition().duration(500).attr('fill', '#f8bd4f').style('cursor', 'default');

        d3.select(".chart-wrapper_points .tooltip").style('opacity', '0').style('padding', '0 5px 0 5px').select('.tooltip__text').remove();
    });

    // circle
    var circle = point.append('circle').attr('class', 'point__circle').attr('fill', '#f8bd4f').attr('cx', function (d) {
        return x(d.date);
    }).attr('cy', height).transition().duration(1500).attr('cy', function (d) {
        return y(d.value);
    })
    // .attr('r', function (d){
    //     return r(Math.sqrt(d.date)); })
    .attr('r', RADIUS).attr('data-country', function (d) {
        return d.value;
    });

    // let axis_top = svg__axis.append('g');
    //     .attr('class', 'axis__x axis__x_top')
    //     .attr('transform', 'translate(0 ,' + (- 10) +')')
    //     .call(
    //         d3.svg.axis()
    //             .scale(x)
    //             .orient('top')
    //     );
    var axis_bottom = svg__axis.append('g').attr('class', '.chart-wrapper_points axis__x axis__x_bottom').attr('transform', 'translate(0,' + height + ')').call(d3.svg.axis().scale(x).orient('bottom'));
    var axis_left = svg__axis.append('g').attr('class', '.chart-wrapper_points axis__y').call(d3.svg.axis().scale(y).orient('left'));

    // создаем набор вертикальных линий для сетки
    d3.selectAll(".chart-points g.axis__x g.tick").append("line") // добавляем линию
    .classed("grid-line", true) // добавляем класс
    .attr("x1", 0).attr("y1", 0).attr("x2", 0).attr("y2", -height);

    // рисуем горизонтальные линии
    d3.selectAll(".chart-points g.axis__y g.tick").append("line").classed("grid-line", true).attr("x1", 0).attr("y1", 0).attr("x2", width).attr("y2", 0);
}

draw(data_point);
//# sourceMappingURL=d3v3.js.map
