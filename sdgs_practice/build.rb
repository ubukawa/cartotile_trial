require 'json'

data = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = {}}}
max = {
  :values => 0, 
}
first = true
while gets
  if first
    first = false
    next
  end
  r = $_.strip.split(',')
  values = r[3].to_i
  years = r[4].to_i
 
  data[r[0]][r[1]] = {
    :names2 => r[2],
    :values => values,
    :years => years,
    :unit => r[5]  
  }
  max[:values] = [max[:values], values].max
end

print <<-EOS
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title></title>
<link rel="stylesheet" type="text/css" href="mapbox-gl.css">
<style>
body { margin: 0; top: 0; bottom: 0; width: 100%; }
#map { position: absolute; top: 0; bottom: 0; width: 100%; }
</style>
<script src="mapbox-gl.js"></script>
</head>
<body>
<div id="map"></div>
<script type="module">
const data = #{JSON.pretty_generate(data)}
const max = #{JSON.pretty_generate(max)} 

const INDEX = '1.1.1'
const TYPE = 'values'

const indexData = data[INDEX]
console.log(indexData)

let MAPCLR
let MAPLAB
let table = []
let iso3cds = []
for (let iso3cd in indexData) {
  iso3cds.push(iso3cd)
  const g = 
    indexData[iso3cd][TYPE] / 
    max[TYPE]
  if (table[g]) {
    table[g].push(iso3cd)
  } else {
    table[g] = [iso3cd]
  }
}
let fillExpression = [
  'match',
  [
    'get',
    'MAPCLR'
  ]
]
for (let g in table) {
  fillExpression.push(table[g])
  fillExpression.push('hsl(' + parseInt(60 - g * 60) + ', 100%, 50%)')
}
fillExpression.push([
  'rgb',
  250,
  250,
  250
])

const map = new mapboxgl.Map({
  container: 'map',
  style: 'https://ubukawa.github.io/nat-tile/style.json',
  attributionControl: true,
  hash: true,
  renderWorldCopies: false
})
map.addControl(new mapboxgl.NavigationControl())

let match1 = [
  'match',
  [
    'get',
    'MAPCLR'
  ]
]
let match2 = [
  'match',
  [
    'get',
    'MAPCLR'
  ]
]
let match3 = [
  'match',
  [
    'get',
    'MAPCLR'
  ]
]
for (let iso3cd in indexData) {
  match1.push(iso3cd)
  match1.push(indexData[iso3cd]['values'].toString())
  match2.push(iso3cd)
  match2.push([
    'concat',
    [
      'get',
      'MAPCLR'
    ],
    ': ',
    indexData[iso3cd][TYPE]
  ])
  match3.push(iso3cd)
  match3.push([
    'concat',
    [
      'get',
      'MAPLAB'
    ],
    ': ',
    indexData[iso2cd][TYPE],
    ' ',
    TYPE
  ])
}
match1.push('?')
match2.push('?')
match3.push('?')

const textFieldExpression = [
  'step',
  [
    'zoom'
  ],
  match1,
  1,
  match2,
  3,
  match3
]

const fillExtrusionHeight = [
  'match',
  [
    'get',
    'MAPCLR'
  ]
]
for (let iso3cd in indexData) {
  fillExtrusionHeight.push([iso3cd])
  fillExtrusionHeight.push(indexData[iso3cd][TYPE] * 100)
}
fillExtrusionHeight.push(0)
console.log(fillExtrusionHeight)

map.on('load', () => {
  map.getSource('v').attribution += 
    ` | number of ${TYPE} on ${INDEX} for test`
  console.log(map.getSource('v').attribution)
  map.setPaintProperty(
    'bnda',
    'fill-color',
    fillExpression
  )
  map.setLayoutProperty(
    'text',
    'text-field',
    textFieldExpression
  )
  map.setPaintProperty(
    'text',
    'text-color',
    [
      'match',
      [
        'get',
        'MAPCLR'
      ],
      iso3cds,
      [
        'rgb',
        0,
        0,
        0
      ],
      [
        'rgb',
        250,
        250,
        250
      ]
    ]
  )
  map.addLayer({
    id: 'bnda-extrusion',
    source: 'v',
    'source-layer': 'bnda',
    type: 'fill-extrusion',
    paint: {
      'fill-extrusion-height': fillExtrusionHeight,
      'fill-extrusion-color': fillExpression,
      'fill-extrusion-opacity': 0.2
    } 
  })
})
</script>
</body>
</html>
EOS

