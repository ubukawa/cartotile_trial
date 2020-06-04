require 'json'

data = Hash.new {|h, k| h[k] = Hash.new {|h, k| h[k] = {}}}
max = {
  :deaths => 0, 
  :cumulativeDeaths => 0,
  :confirmed => 0,
  :cumulativeConfirmed => 0
}
first = true
while gets
  if first
    first = false
    next
  end
  r = $_.strip.split(',')
  deaths = r[4].to_i
  cumulativeDeaths = r[5].to_i
  confirmed = r[6].to_i
  cumulativeConfirmed = r[7].to_i

  data[r[0]][r[1].downcase] = {
    :name => r[2],
    :deaths => deaths,
    :cumulativeDeaths => cumulativeDeaths,
    :confirmed => confirmed,
    :cumulativeConfirmed => cumulativeConfirmed
  }
  max[:deaths] = [max[:deaths], deaths].max
  max[:cumulativeDeaths] = [max[:cumulativeDeaths], cumulativeDeaths].max
  max[:confirmed] = [max[:confirmed], confirmed].max
  max[:cumulativeConfirmed] =
    [max[:cumulativeConfirmed], cumulativeConfirmed].max
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

const DATE = '2020-04-17'
const TYPE = 'confirmed'

const dailyData = data[DATE]
console.log(dailyData)

let ISO_A2
let table = []
let iso2cds = []
for (let iso2cd in dailyData) {
  iso2cds.push(iso2cd)
  const g = 
    dailyData[iso2cd][TYPE] / 
    max[TYPE]
  if (table[g]) {
    table[g].push(iso2cd.toUpperCase())
  } else {
    table[g] = [iso2cd.toUpperCase()]
  }
}
let fillExpression = [
  'match',
  [
    'get',
    'ISO_A2'
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
  style: 'https://ubukawa.github.io/nat-tile/style_r.json',
  attributionControl: true,
  hash: true,
  renderWorldCopies: false
})
map.addControl(new mapboxgl.NavigationControl())

let match1 = [
  'match',
  [
    'get',
    'ISO_A2'
  ]
]
let match2 = [
  'match',
  [
    'get',
    'ISO_A2'
  ]
]
let match3 = [
  'match',
  [
    'get',
    'ISO_A2'
  ]
]
for (let iso2cd in dailyData) {
  match1.push(iso2cd.toUpperCase())
  match1.push(dailyData[iso2cd]['confirmed'].toString())
  match2.push(iso2cd.toUpperCase())
  match2.push([
    'concat',
    [
      'get',
      'ISO_A3'
    ],
    ': ',
    dailyData[iso2cd][TYPE]
  ])
  match3.push(iso2cd.toUpperCase())
  match3.push([
    'concat',
    [
      'get',
      'NAME'
    ],
    ': ',
    dailyData[iso2cd][TYPE],
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
  2,
  match2,
  4,
  match3
]

const fillExtrusionHeight = [
  'match',
  [
    'get',
    'ISO_A2'
  ]
]
for (let iso2cd in dailyData) {
  fillExtrusionHeight.push([iso2cd.toUpperCase()])
  fillExtrusionHeight.push(dailyData[iso2cd][TYPE] * 100)
}
fillExtrusionHeight.push(0)
console.log(fillExtrusionHeight)

map.on('load', () => {
  map.getSource('v').attribution += 
    ` | number of ${TYPE} on ${DATE} from WHO`
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
        'ISO_A2'
      ],
      ISO_A2,
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

