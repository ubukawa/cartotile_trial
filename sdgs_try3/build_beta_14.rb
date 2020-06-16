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
 
  data[r[0]][r[1].downcase] = {
    :names => r[2],
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

const INDEX = '14.a.1'
const unit = "percent"
const TYPE = 'values'

const indexData = data[INDEX]
console.log(indexData)

let ISO_A2
let table = []
let iso3cds = []
let iso2cds = []
for (let iso2cd in indexData) {
  iso3cds.push(indexData[iso2cd]['names'])
  iso2cds.push(iso2cd)
  const g = 
    indexData[iso2cd][TYPE] / 
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
  style: 'https://ubukawa.github.io/nat-tile/style_0616.json',
  attributionControl: true,
  hash: true,
  renderWorldCopies: false
})
map.addControl(new mapboxgl.NavigationControl())

let match1 = [
  'match',
  [
    'get',
    'ISO3CD'
  ]
]
let match2 = [
  'match',
  [
    'get',
    'ISO3CD'
  ]
]
let match3 = [
  'match',
  [
    'get',
    'ISO3CD'
  ]
]
for (let iso2cd in indexData) {
  match1.push(indexData[iso2cd]['names'].toUpperCase())
  match1.push(indexData[iso2cd]['values'].toString())
  match2.push(indexData[iso2cd]['names'].toUpperCase())
  match2.push([
    'concat',
    [
      'get',
      'ISO3CD'
    ],
    ': ',
    indexData[iso2cd][TYPE]
  ])
  match3.push(indexData[iso2cd]['names'].toUpperCase())
  match3.push([
    'concat',
    [
      'get',
      'MAPLAB'
    ],
    ': ',
    indexData[iso2cd][TYPE],
    ' ',
    unit
  ])
}
match1.push('')
match2.push('NA')
match3.push('No data')

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
        'ISO3CD'
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

})
</script>
</body>
</html>
EOS

