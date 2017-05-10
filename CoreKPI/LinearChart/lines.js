"use strict";

// // Данные для чарта

function draw(data) {
    // const title = 'СЮДА НАЗВАНИЕ ЕЕЕЕЕЕ';
    var lineChartWidth = document.body.clientWidth;
    var lineChartHeight = document.body.clientHeight;
    var margin = { top: 50, right: 30, bottom: 30, left: 30 };
    var width = void 0,
        height = void 0,
        svg_wraper = void 0,
        svg = void 0;

    width = lineChartWidth - (margin.left + margin.right);
    height = lineChartHeight - (margin.top + margin.bottom);

    svg_wraper = d3.select(".chart-wrapper.chart-wrapper_linechart").attr("style", "width: " + (width + margin.left + margin.right) + "px; height: " + (height + margin.top + margin.bottom) + "px").style("margin", "auto").style("position", "relative");

    svg = d3.select("#chart-linechart").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("class", "chart__cnt").attr("transform", "translate(" + 50 + "," + margin.top + ")");

    // добавляем заголовок
    svg.append("text").attr("x", 0).attr("y", -15).attr("text-anchor", "start").attr("fill", "#ffffff").style("font-size", "22px");
    // .text(title);

    // lineChart(data);

    var format = d3.time.format.multi([[".%L", function (d) {
        return d.getMilliseconds();
    }], [":%S", function (d) {
        return d.getSeconds();
    }], ["%I:%M", function (d) {
        return d.getMinutes();
    }], ["%I %p", function (d) {
        return d.getHours();
    }], ["%a %d", function (d) {
        return d.getDay() && d.getDate() != 1;
    }], ["%b %d", function (d) {
        return d.getDate() != 1;
    }], ["%B", function (d) {
        return d.getMonth();
    }], ["%Y", function () {
        return true;
    }]]);

    var w = lineChartWidth;
    var h = lineChartHeight;

    var maxValue = d3.max([d3.max(data[data.length - 1], function (d) {
        return d.rate;
    })]);

    var minValue = d3.min([d3.min(data[0], function (d) {
        return 1;
    })]);

    // функция интерполяции значений на ось Х
    var scaleX = d3.time.scale().domain([d3.min(data[0], function (d) {
        return d.date;
    }), d3.max(data[data.length - 1], function (d) {
        return d.date;
    })]).range([0, width - margin.left]);

    // функция интерполяции значений на ось Y
    var scaleY = d3.scale.linear().domain([maxValue + 0.5, minValue - 0.5]).range([0, height]);

    var xAxis = d3.svg.axis().scale(scaleX)
    // .orient("bottom")
    // .tickFormat(d3.format('000'));
    // .tickFormat(d3.time.format('%e.%m'));
    .tickFormat(d3.time.format('%d %b'));

    var yAxis = d3.svg.axis().scale(scaleY).orient('left');

    var svg__axis = svg.append("g").attr("class", "axis").attr("width", width).attr("height", height);

    // отрисовка оси Х
    svg__axis.append("g").attr("class", "axis__x").attr("transform", // сдвиг оси вниз и вправо
    "translate(" + 0 + "," + height + ")").call(xAxis);

    svg__axis.append('g').attr('class', 'axix__y').attr("transform", // сдвиг оси вниз и вправо
    "translate(" + 0 + "," + 0 + ")").call(yAxis);

    // создаем набор вертикальных линий для сетки
    d3.selectAll(".chart-wrapper_linechart g.axis__x g.tick").append("line") // добавляем линию
    .classed("grid-line", true) // добавляем класс
    .attr("x1", 0).attr("y1", 0).attr("x2", 0).attr("y2", -height);

    // рисуем горизонтальные линии
    d3.selectAll(".chart-wrapper_linechart g.axix__y g.tick").append("line").classed("grid-line", true).attr("x1", 0).attr("y1", 0).attr("x2", width - margin.left).attr("y2", 0);

    data.forEach(function (el) {
        createChart(el, "#6de1b1", "usd");
    });

    // общая функция для создания графиков
    function createChart(data, colorStroke, label) {
        var linePath = svg.append('g').attr('class', 'linePath');
        // функция, создающая по массиву точек линии
        var line = d3.svg.line().x(function (d) {
            return scaleX(d.date);
        }).y(function (d) {
            return scaleY(d.rate);
        }).interpolate('linear');

        var lineCardinal = d3.svg.line().x(function (d) {
            return scaleX(d.date);
        }).y(function (d) {
            return scaleY(d.rate);
        }).interpolate('cardinal');

        var linePath__name = linePath.append("path")
        // this block == path in css
        .style('stroke-dasharray', 1000).style('stroke-dashoffset', 1000).style('animation', 'dash 2s linear forwards')
        // end animation
        .attr("d", lineCardinal(data)).attr("class", "linePath__" + label + "").style("stroke", colorStroke).style("stroke-width", 2);

        // добавляем отметки к точкам
        var circle = svg.append('g').attr("class", "circle");

        var circleTag = circle.selectAll(".dot " + label).data(data).enter().append("circle");

        circleTag.style("stroke", colorStroke).style("stroke-width", 3).style("fill", "white").attr("class", "dot dot__" + label).attr("r", 6).attr("cx", function (d) {
            return scaleX(d.date);
        }).attr("cy", function (d) {
            return scaleY(d.rate);
        });

        circleTag
        // .on("click", circleTagClick);

        .on('mouseover', function (d) {
            d3.select(this).transition().duration(100).attr("cursor", "pointer").style("stroke", "#ffffff");

            d3.select('.chart-wrapper_linechart .tooltip').transition().duration(100).style('top', '' + scaleY(d.rate) + 'px').style('left', '' + (scaleX(d.date) + 20) + 'px').style('display', 'block');

            d3.select('.chart-wrapper_linechart .tooltip').append("span").attr('class', 'tooltip__text').html(d.rate);
        }).on('mouseout', function (d) {
            d3.select(this).attr("cursor", "default").style("stroke", colorStroke);

            d3.select('.chart-wrapper_linechart .tooltip').style('display', 'none').select('.tooltip__text').remove();
        });
    }
}

draw(dataIn);
//# sourceMappingURL=d3v3.js.map
