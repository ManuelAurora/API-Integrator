var data_pie = [
                {number: "Week 1", rate: numOne},
                {number: "Week 2", rate: numTwo},
                {number: "Week 3", rate: numThree},
                {number: "Week 4", rate: numFour},
                {number: "Week 5", rate: numFive}
                ];

function pie(w, h, data) {
    var margin = 10;
    var width = w, height = h;
    var radius = Math.min(width - margin, height - margin) / 2 * 0.9, outerRadius = radius - margin, innerRadius = 0;
    var color = d3.scale.ordinal().range([
                                          '#30a5e3',
                                          '#ee5de0',
                                          '#d0e868',
                                          '#29e3b6',
                                          '#2dc7da'
                                          ]);
    var svg_wraper = d3.select('.chart-wrapper.chart-wrapper_pie').attr('style', 'width:' + width + 'px;' + 'height:' + height + 'px').style('margin', 'auto').style('position', 'relative');
    var svg = d3.select('#chart-pie').attr('class', 'axis chart chart-pie').attr('width', width).attr('height', height).append('g').attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');
    var tooltip_pie = d3.select('.chart-wrapper_pie .tooltip.tooltip-pie');
    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__title').text('Gross Revenue');
    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__value').text('testValue');
    tooltip_pie.append('div', '').attr('class', 'tooltip-pie__status');
    var tooltip_pie__value = document.querySelector('.chart-wrapper_pie .tooltip-pie__value');
    var arc = d3.svg.arc().outerRadius(outerRadius).innerRadius(innerRadius);
    var pie = d3.layout.pie().sort(null).value(function (d) {
                                               return d.rate;
                                               });
    var g = svg.selectAll('.chart-wrapper_pie .arc').data(pie(data)).enter().append('g').attr('class', 'arc').style('transform', 'scale(1)').style('opacity', 0.7).on('click', function (d) {
                                                                                                                                                                      if (this.classList.contains('arc_active')) {
                                                                                                                                                                      tooltip_pie.style('visibility', 'hidden');
                                                                                                                                                                      tooltip_pie.style('opacity', 0);
                                                                                                                                                                      d3.select(this).classed('arc_active', false).transition().duration(200).ease('linear').style('opacity', 0.7);
                                                                                                                                                                      } else {
                                                                                                                                                                      tooltip_pie__value.textContent = accounting.formatMoney(d.value, '');
                                                                                                                                                                      tooltip_pie.style('visibility', 'visible');
                                                                                                                                                                      tooltip_pie.style('left', function () {
                                                                                                                                                                                        return arc.centroid(d)[0] + width / 2 - 65 + 'px';
                                                                                                                                                                                        });
                                                                                                                                                                      tooltip_pie.style('top', function () {
                                                                                                                                                                                        return arc.centroid(d)[1] + height / 2 - 80 + 'px';
                                                                                                                                                                                        });
                                                                                                                                                                      tooltip_pie.style('opacity', 1);
                                                                                                                                                                      d3.selectAll('.chart-wrapper_pie .arc').classed('arc_active', false).transition().duration(200).ease('linear').style('opacity', 0.7);
                                                                                                                                                                      d3.select(this).classed('arc_active', true).transition().duration(200).ease('linear').style('opacity', 1);
                                                                                                                                                                      }
                                                                                                                                                                      });
    shadowOwerlay(svg, 'arc-shadow', 130, 2, 0, 1);
    shadowOwerlay(svg, 'g-shadow', 150, 10, 20, 20);
    function shadowOwerlay(level, id, filterHeight, blurValue, dx, dy) {
        'use strict';
        var defs = level.append('defs').attr('class', 'filter_' + id + '');
        var filter = defs.append('filter').attr('id', id).attr('height', filterHeight + '%');
        filter.append('feGaussianBlur').attr('in', 'SourceAlpha').attr('stdDeviation', blurValue).attr('result', 'blur');
        filter.append('feOffset').attr('in', 'blur').attr('dx', dx).attr('dy', dy).attr('result', 'offsetBlur');
        var feMerge = filter.append('feMerge');
        feMerge.append('feMergeNode').attr('in', 'offsetBlur');
        feMerge.append('feMergeNode').attr('in', 'SourceGraphic');
    }
    g.append('path').attr('d', arc).attr('class', 'arc__path').style('fill', function (d) {
                                                                     return color(d.data.number);
                                                                     });
    g.append('text').attr('class', function (d) {
                          var str = '';
                          if (str.replace(/\s/g, '') == '') {
                          str = d.data.number;
                          }
                          return 'arc__text arc__text_' + str.replace(/\s+/g, '-').toLowerCase();
                          }).attr('transform', function (d) {
                                  return 'translate(' + arc.centroid(d) + ')';
                                  }).style('text-anchor', 'middle').style('font-size', '12px').style('fill', '#fff').style('font-weight', 'normal').text(function (d) {
                                                                                                                                                         return d.data.number;
                                                                                                                                                         });
}
