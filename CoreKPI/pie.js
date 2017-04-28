'use strict';

//var data_pie = [{
//    name: 'Week 1',
//    rate: 100
//}, {
//    name: 'Week 1',
//    rate: 50
//}, {
//    name: 'Week 1',
//    rate: 20
//}, {
//    name: 'Week 1',
//    rate: 100
//}, {
//    name: 'Week 1',
//    rate: 50
//}, {
//    name: 'Week 1',
//    rate: 20
//}];

function pie(data) {
    var colToHex = function colToHex(c) {
        var color = c < 75 ? c + 75 : c;
        var hex = color.toString(16);
        return hex.length == 1 ? "0" + hex : hex;
    };

    var rgbToHex = function rgbToHex(r, g, b) {
        return "#" + colToHex(r) + colToHex(g) + colToHex(b);
    };

    var generateColor = function generateColor() {
        return rgbToHex(Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), Math.floor(Math.random() * 255));
    };

    data.forEach(function (element) {
        element.color = generateColor();
    });

    var margin = 10;
    var width = document.body.clientWidth - 10;;
    var height = document.body.clientHeight;
    var radius = Math.min(width - margin, height - margin) * 0.6;
    var outerRadius = radius - margin;
    var innerRadius = 0;
    var container = document.querySelector('.chart-wrapper_pie');
    var parent = document.createElement('div');
    //var title = 'Title Pie';

    parent.className = 'legend-pie';
    document.querySelector('.title').textContent = title;

    data.forEach(function (element, i) {
        var template = document.createElement('div');
        template.className = 'legend-pie__row';
        template.innerHTML = '\n            <div class=\'legend-pie__color\'></div>\n            <div class=\'legend-pie__name\'>' + element.name + '</div>';
        parent.appendChild(template);
        container.appendChild(parent);
    });

    var paths = document.querySelectorAll('.legend-pie__color');

    paths.forEach(function (element, i) {
        return element.style.backgroundColor = data[i].color;
    });

    //svg wrapper
    var svg_wraper = d3.select('.chart-wrapper.chart-wrapper_pie')
    // .attr('style',
    //     'width:'+(width)+'px;'+
    //     'height:'+(height)+'px')
    .style('width', '100%').style('height', '70vh').style('margin', 'auto')
    // .style('margin-right', 'auto')
    .style('position', 'relative');

    //svg
    var svg = d3.select('#chart-pie').attr('class', 'axis chart chart-pie').attr('width', '100%').attr('height', '55vh').append('g').attr('class', 'pie-centroid').attr('style', 'transform: translateX(' + width / 2 + 'px)translateY(' + height * 0.7 + 'px)');

    var tooltip_pie = d3.select('.tooltip.tooltip-pie');

    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__title').text('Gross Revenue');
    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__value').text('testValue');
    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__status');

    var tooltip_pie__value = document.querySelector('.chart-wrapper_pie .tooltip-pie__value');

    //create arc
    var arc = d3.svg.arc().outerRadius(outerRadius).innerRadius(innerRadius);

    var pie = d3.layout.pie().sort(null).value(function (d) {
        if (d.rate !== 0) {
            return d.rate;
        } else {
            return 1;
        }
    });

    //create arc
    var g = svg.selectAll('.chart-wrapper_pie .arc').data(pie(data)).enter().append('g').attr('class', 'arc').style('transform', 'scale(1)').style('opacity', 0.7).on('click', function (d) {
        if (this.classList.contains('arc_active')) {
            tooltip_pie.style('visibility', 'hidden');
            tooltip_pie.style('opacity', 0);

            d3.select(this).classed('arc_active', false).transition().duration(200).ease('linear').style('opacity', 0.7);
        } else {

            tooltip_pie__value.textContent = d.value;
            tooltip_pie.style('visibility', 'visible');
            tooltip_pie.style('left', function () {
                return arc.centroid(d)[0] + width / 2 - document.querySelector('.tooltip.tooltip-pie').offsetWidth / 2 + 'px';
            });
            // tooltip_pie.style('top', function () {
            //     return arc.centroid(d);
            // });
            // tooltip_pie.style('top', function () {
            //     return (arc.centroid(d)[1]) + height / 2 - (document.querySelector('.tooltip.tooltip-pie').offsetHeight) - 20 + 'px';
            // });
            tooltip_pie.style('left', function () {
                return arc.centroid(d)[0] + width / 2 - 65 + 'px';
            });
            tooltip_pie.style('top', function () {
                return arc.centroid(d)[1] + height - 80 + 'px';
            });
            tooltip_pie.style('opacity', 1);

            d3.selectAll('.chart-wrapper_pie .arc').classed('arc_active', false).transition().duration(200).ease('linear').style('opacity', 0.7);

            d3.select(this).classed('arc_active', true).transition().duration(200).ease('linear').style('opacity', 1);
        }
    });

    //create path
    g.append('path').attr('d', arc).attr('class', 'arc__path').style('fill', function (d) {
        return d.data.color;
    }).style('fill', '#pie-filter');
}

pie(data_pie);
//# sourceMappingURL=pie.js.map
