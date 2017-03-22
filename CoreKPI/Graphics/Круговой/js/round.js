//var data_pie = [
//                {number: "Week 1", rate: numOne},
//                {number: "Week 2", rate: numTwo},
//                {number: "Week 3", rate: numThree},
//                {number: "Week 4", rate: numFour},
//                {number: "Week 5", rate: numFive}
//                ];

function pie(w, h, data) {
    var margin = 10;
    var width = w,
    height = h;
    
    var radius = ((Math.min((width - margin), (height - margin)) / 2) * 0.9  ),
    outerRadius = radius - margin,
    innerRadius = 0,
    
    MAGIC__WALLY = 2.25;
    
    var color = d3.scale.ordinal().range([
                                          '#30a5e3', '#ee5de0', '#d0e868', '#29e3b6', '#2dc7da'
                                          ]);
    
    //svg wrapper
    var svg_wraper = d3.select('.chart-wrapper.chart-wrapper_pie')
    .attr('style',
          'width:'+(width)+'px;'+
          'height:'+(height)+'px')
    .style('margin', 'auto')
    .style('position', 'relative');
    
    //svg
    var svg = d3.select('#chart-pie')
    .attr("class", "axis chart chart-pie")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr('class', 'pie-centroid')
    .attr("transform", "translate(" +(width / 2) + "," + ((height / MAGIC__WALLY) ) + ")");
    // .style('filter', 'drop-shadow( 2em 2em 13px rgba(0,0,0, 0.5))');
    
     //text title
     var title = svg_wraper
     	.append('div')
     		.attr('class', 'chart-title')
     		.text('Weekly')
    
    var tooltip_pie = d3.select('.chart-wrapper_pie .tooltip.tooltip-pie');
    
    tooltip_pie.append('div', '')
        .attr('class', 'tooltip-pie__title')
        .text('Gross Revenue');
    tooltip_pie.append('div', '')
        .attr('class', 'tooltip-pie__value')
        .text('testValue');
    tooltip_pie.append('div', '')
        .attr('class', 'tooltip-pie__status');
    
    var tooltip_pie__value = document.querySelector('.chart-wrapper_pie .tooltip-pie__value');
    
    
    
    //create arc
    var arc = d3.svg.arc()
    .outerRadius(outerRadius)
    .innerRadius(innerRadius);
    
    var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) {
           return d.rate;
           });
    
    //create arc
    var g = svg.selectAll(".chart-wrapper_pie .arc")
    .data(pie(data))
    .enter()
    .append("g")
    .attr("class", "arc")
    .style("transform", "scale(1)")
    .style("opacity", 0.7)
    .on("click", function (d) {
        if( this.classList.contains('arc_active') ){
        tooltip_pie.style('visibility', 'hidden')
        tooltip_pie.style('opacity', 0);
        
        d3.select(this)
        .classed('arc_active', false)
        .transition()
        .duration(200)
        .ease("linear")
        .style("opacity", 0.7)
        // .style("transform", "scale(1")
        } else {
        tooltip_pie__value.textContent = accounting.formatMoney(d.value, '');
        tooltip_pie.style('visibility', 'visible');
        tooltip_pie.style('left', function () {
                          // console.log((document.querySelector('.tooltip.tooltip-pie').offsetWidth / 2) + 'px');
                          return (arc.centroid(d)[0] + width / 2) - (document.querySelector('.tooltip.tooltip-pie').offsetWidth / 2) + 'px';
                          });
        tooltip_pie.style('top', function () {
                          return arc.centroid(d);
                          });
        tooltip_pie.style('top', function () {
                          console.log()
                          return (arc.centroid(d)[1]) + height / MAGIC__WALLY - (document.querySelector('.tooltip.tooltip-pie').offsetHeight) - 20 + 'px';
                          });
        // tooltip_pie.style('left', function () {
        //     return arc.centroid(d)[0] + width / 2 - 65 + 'px';
        // });
        // tooltip_pie.style('top', function () {
        //     return arc.centroid(d)[1] + height / 2 - 80 + 'px';
        // });
        tooltip_pie.style('opacity', 1);
        
        d3.selectAll('.chart-wrapper_pie .arc')
        .classed('arc_active', false)
        .transition()
        .duration(200)
        .ease("linear")
        .style("opacity", 0.7);
        // .style("transform", "scale(1")
        
        d3.select(this)
        .classed('arc_active', true)
        .transition()
        .duration(200)
        .ease("linear")
        
        .style("opacity", 1);
        // .style("transform", "scale(1.1")
        }
        });
    
    shadowOwerlay(svg, 'arc-shadow', 130, 3, 0, 0);
    shadowOwerlay(svg, 'g-shadow', 150, 10, 20, 20);
    
    function shadowOwerlay(level, id, filterHeight, blurValue, dx, dy){
        "use strict";
        // filters go in defs element
        let defs = level.append("defs")
        .attr('class', 'filter_'+id+'');
        
        // create filter with id #drop-shadow
        // height=130% so that the shadow is not clipped
        let filter = defs.append("filter")
        .attr("id", id)
        .attr("height", filterHeight+"%");
        
        // SourceAlpha refers to opacity of graphic that this filter will be applied to
        // convolve that with a Gaussian with standard deviation 3 and store result
        // in blur
        filter.append("feGaussianBlur")
        .attr("in", "SourceAlpha")
        .attr("stdDeviation", blurValue)
        .attr("result", "blur");
        
        // translate output of Gaussian blur to the right and downwards with 2px
        // store result in offsetBlur
        filter.append("feOffset")
        .attr("in", "blur")
        .attr("dx", dx)
        .attr("dy", dy)
        .attr("result", "offsetBlur");
        
        // overlay original SourceGraphic over translated blurred opacity by using
        // feMerge filter. Order of specifying inputs is important!
        var feMerge = filter.append("feMerge");
        
        feMerge.append("feMergeNode")
        .attr("in", "offsetBlur");
        feMerge.append("feMergeNode")
        .attr("in", "SourceGraphic");
        
        
        //
        // var gradientForegroundPurple = defs.append( 'linearGradient' )
        //     .attr( 'id', 'gradientForegroundPurple' )
        //     .attr( 'x1', '0' )
        //     .attr( 'x2', '0' )
        //     .attr( 'y1', '0' )
        //     .attr( 'y2', '1' );
        //
        // gradientForegroundPurple.append( 'stop' )
        //     .attr( 'class', 'purpleForegroundStop1' )
        //     .attr( 'offset', '0%' );
        //
        // gradientForegroundPurple.append( 'stop' )
        //     .attr( 'class', 'purpleForegroundStop2' )
        //     .attr( 'offset', '100%' );
    }
    
    
    
    //create path
    g.append("path")
    .attr("d", arc)
    .attr("class", 'arc__path')
    .style("fill", function(d) {
           return color(d.data.number);
           })
    .style("fill", '#pie-filter');
    
    // g.append('circle')
    //     .attr("transform", function(d) {
    //         // console.log(arc.centroid(d));
    //         return "translate(" + arc.centroid(d) + ")";
    //     })
    //     .attr('r', '0.1em')
    //     .attr('fill', 'red');
    //create text
    g.append("text")
    .attr("class", function(d) {
          var str = '';
          if(str.replace(/\s/g,'')==''){
          str = (d.data.number);
          }
          return "arc__text arc__text_"+ (str.replace(/\s+/g,'-')).toLowerCase();
          })
    .attr("transform", function(d) {
          // console.log(arc.centroid(d));
          return "translate(" + arc.centroid(d) + ")";
          })
    .style("text-anchor", "middle")
    .attr("dy", "0.3em")
    .style('background', 'blue')
    .style("font-size", "1.2em")
    .style("line-height", "1")
    .style("fill", "#fff")
    .style("font-weight", "normal")
    .text(function(d) {
          return d.data.number;
          });
    
}

