var SUMM = 1100;
var Funnel = function () {
    var data = [];
    
    var data = [
                ['Step 1', 400, '#87d37c'],
                ['Step 2', 200, '#36d7b7'],
                ['Step 3', 150, '#c8f7c5'],
                ['Step 4', 350, '#3fc380'],
                ];
    
    var options = {
    chart: {
				bottomWidth: 1 / 2,
				bottomPinch: 0,
    },
    block: {
        // minHeight: 40,
				dynamicHeight: true,
        // dynamicSlope: true,
				highlight: true
    },
    label: {
				format: '{l}\n{f}',
				fontFamily: 'Open Sans',
				fontSize: '12px',
				fill: '#fff',
    },
    };
    
    (new D3Funnel('#funnel-chart')).draw(data, options);
};
Funnel();
