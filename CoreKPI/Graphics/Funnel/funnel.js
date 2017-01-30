//var SUMM = 1100;
//var Funnel = function () {
//    var data = [];
//    
//    var data = [
//                ['Step 1', 400, '#87d37c'],
//                ['Step 2', 200, '#36d7b7'],
//                ['Step 3', 150, '#c8f7c5'],
//                ['Step 4', 350, '#3fc380'],
//                ];
//    
//    var options = {
//    chart: {
//				bottomWidth: 1 / 2,
//				bottomPinch: 0,
//    },
//    block: {
//        // minHeight: 40,
//				dynamicHeight: true,
//        // dynamicSlope: true,
//				highlight: true
//    },
//    label: {
//				format: '{l}\n{f}',
//				fontFamily: 'Open Sans',
//				fontSize: '12px',
//				fill: '#fff',
//    },
//    };
//    
//    (new D3Funnel('#funnel-chart')).draw(data, options);
//};
//Funnel();


"use strict";

function funnel_d3v4(id, heightCoef, bottomWidthCoef) {
    // funnel_d3v4(id, [heightCoef, bottomWidthCoef]);
    
    /* where
     id                  - идентификатор нашей воронки, которая в себе содержит svg
     heightCoef          - коефициет для определения высоты воронки
     [default = 0.5]
     bottomWidthCoef     - коефициет для определения высоты крайней правой линии воронки [0, 1]
     [default = 0.000001] || [default = 1 / 1000000]
     */
    
    var funnel__chart = document.querySelector(id);
    var funnel = funnel__chart.parentNode.parentNode;
    var funnel__chart_wrapper = funnel__chart.parentNode;
    var funnel__width = funnel__chart_wrapper.clientWidth;
    var funnel__svg = funnel__chart.children[0];
    var funnel__collections = funnel.children; // is not Array
    var funnel__label = funnel.children[getIndex(funnel__collections, 'funnel__label')];
    var funnel__labelTable = funnel__label.children[0];
    
    var funnel__persent = funnel.children[getIndex(funnel__collections, 'funnel__persent')];
    var funnel__persentTable = funnel__persent.children[0];
    
    function isCollection(collection) {
        "use strict";
        
        var array = void 0;
        if (!Array.isArray(collection)) {
            array = Array.prototype.slice.call(collection);
            // console.log('1 ' + Array.isArray(collection));
            return array;
        } else {
            array = collection;
            return array;
        }
    }
    
    function getIndex(collection, findSelector) {
        "use strict";
        
        var index = void 0;
        var array = isCollection(collection);
            for (var i = 0; i < array.length; i++) {
            // console.log(label[i].classList.contains(collection));
            if (array[i].classList.contains(findSelector)) {
                index = i;
                // console.log(index);
                return index;
            }
        }
    }
    
    
    if (heightCoef === undefined) {
        heightCoef = 0.5;
    }
    if (bottomWidthCoef === undefined) {
        bottomWidthCoef = 1 / 1000000; // при таком значении соберется в точку
    }
    
    var dataByFunnel = [['Step 1', 300, '#87d37c'], ['Step 2', 200, '#36d7b7'], ['Step 3', 150, '#c8f7c5'], ['Step 4', 350, '#3fc380']];
    
    // console.log(dataByFunnel);
    function summByDataFunnel(data) {
        var dataByFunnel__summ = 0;
        
        for (var i = 0; i < data.length; i++) {
            dataByFunnel__summ += data[i][1];
        }
        
        return dataByFunnel__summ;
    }
    // console.log(summByDataFunnel(dataByFunnel));
    function persentValueByDataFunnel(data) {
        "use strict";
        
        var persent = [];
        
        for (var i = 0; i < data.length; i++) {
            persent[i] = data[i][1] * 100 / summByDataFunnel(data);
        }
        
        for (var _i = 0; _i < data.length; _i++) {
            // console.log(persent[i]);
        }
        return persent;
    }
    
    function nameValueByDataFunnel(data) {
        "use strict";
        
        var name = [];
        
        for (var i = 0; i < data.length; i++) {
            name[i] = data[i][0];
        }
        return name;
    }
    
    // console.log(persentValueByDataFunnel(dataByFunnel));
    
    function tebleCells(table, needType, dataRes, selectorAppend) {
        function createTr(selectorAppend) {
            var tr = document.createElement('tr');
            selectorAppend.appendChild(tr);
        }
        function createTh(selectorAppend, index) {
            var tr = selectorAppend.children[0];
            var th = document.createElement('th');
            var th__cnt = void 0;
            
            if (needType === "text") {
                th__cnt = document.createTextNode(nameValueByDataFunnel(dataRes)[index]);
            } else {
                th__cnt = document.createTextNode(persentValueByDataFunnel(dataRes)[index].toFixed(1) + '%');
            }
            th.appendChild(th__cnt);
            th.style.width = persentValueByDataFunnel(dataRes)[index].toFixed(1) + '%';
            tr.appendChild(th);
        }
        createTr(selectorAppend);
        
        for (var i = 0; i < dataRes.length; i++) {
            createTh(selectorAppend, i);
        }
    }
    
    tebleCells(isCollection(funnel__labelTable), 'text', dataByFunnel, funnel__labelTable);
    tebleCells(isCollection(funnel__persentTable), 'value', dataByFunnel, funnel__persentTable);
    
    function Funnel(data) {
        var options = {
        chart: {
        bottomWidth: bottomWidthCoef,
        bottomPinch: 0
        },
        block: {
            // minHeight: 40,
        dynamicHeight: true,
            // dynamicSlope: true,
        highlight: true
        },
        label: {
        format: '{l}\n{f}',
        fontFamily: 'inherit',
        fontSize: '12px',
        fill: '#fff'
        }
        };
        new D3Funnel(id).draw(data, options);
        funnel__svg.style.height = funnel__width + 'px';
        funnel__svg.style.width = funnel__width * heightCoef + 'px';
        console.log(funnel__svg.style.height = funnel__width + 'px');
    }
    funnel__chart.style.height = funnel__width + 'px';
    funnel__chart.style.width = funnel__width * heightCoef + 'px';
    funnel__chart.style.transform = 'rotate(-90deg)translateX(0%)translateY(-' + heightCoef * 100 + '%)';
    funnel__chart_wrapper.style.height = funnel__width * heightCoef + 'px';
    
    Funnel(dataByFunnel);
}

funnel_d3v4('#funnel-chart', 0.7);
