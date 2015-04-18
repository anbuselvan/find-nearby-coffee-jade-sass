map = null
service = null
infoWindow = null
currentLocation = null
currentSearchTerm = null
markers = []
obtainingPosition = false
location = new ReactiveVar(null)
error = new ReactiveVar(null)
options =
  enableHighAccuracy: true
  maximumAge: 0

onError = (newError) ->
  error.set newError
  defLoc = new (google.maps.LatLng)(37.760972, -122.455768)
  location.set defLoc
  return

onPosition = (newLocation) ->
  location.set newLocation
  error.set null
  return

startObtainingPosition = ->
  if !obtainingPosition and navigator.geolocation
    navigator.geolocation.getCurrentPosition onPosition, onError, options
    obtainingPosition = true
  return

loadMap = ->
  map = new (google.maps.Map)(document.getElementById('map-canvas'),
    center: currentLocation
    zoom: 10)
  input = $('#input-city')[0]
  autocomplete = new (google.maps.places.Autocomplete)(input)
  autocomplete.bindTo 'bounds', map
  google.maps.event.addListener autocomplete, 'place_changed', ->
    place = autocomplete.getPlace()
    if !place.geometry
      return
    currentLocation = place.geometry.location
    loadMap()
    searchMap()
    return
  return

searchMap = ->
  if currentSearchTerm and currentSearchTerm != ''
    markers = []
    request =
      location: currentLocation
      radius: '500'
      query: currentSearchTerm
    service = new (google.maps.places.PlacesService)(map)
    service.textSearch request, callback
  return

createMarker = (place) ->
  placeLoc = place.geometry.location
  marker = new (google.maps.Marker)(
    map: map
    position: placeLoc)
  google.maps.event.addListener marker, 'click', ->
    infoWindow.setContent '<div><strong>' + place.name + '</strong></div>' + '<div>' + place.street + '</div>'
    infoWindow.open map, this
    return
  markers.push marker
  return

callback = (results, status) ->
  if status == google.maps.places.PlacesServiceStatus.OK
    # Clear previous search results
    Meteor.call 'clearSearchResults'
    i = 0
    while i < results.length
      place = results[i]
      address = place.formatted_address.split(',')
      street = address[0]
      city = address[1]
      data =
        userId: Meteor.userId()
        pid: place.id
        name: place.name
        address: street
        city: city
        img: place.icon
      place.street = street
      createMarker place
      SearchResults.insert data
      i++
  return

Template.googleMap.rendered = ->
  startObtainingPosition()
  @autorun ->
    if !location.get()
      return
    loc = location.get()
    currentLocation = new (google.maps.LatLng)(loc.coords.latitude, loc.coords.longitude)
    loadMap()
    infoWindow = new (google.maps.InfoWindow)
    return
  return

Template.googleMap.helpers {}
Template.googleMap.events 'click #btn-search': (e) ->
  searchTerm = $('#input-search').val()
  if searchTerm and searchTerm.trim() != ''
    currentSearchTerm = searchTerm.trim()
    searchMap()
  return
