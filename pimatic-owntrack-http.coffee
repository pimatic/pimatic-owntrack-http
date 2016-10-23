module.exports = (env) ->
  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'
  _ = env.require 'lodash'
  geolib = require 'geolib'

  # ###PimaticOwntrackHttp class
  class PimaticOwntrackHttp extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("OwnTrackhttpLocationDevice", {
        configDef: deviceConfigDef.OwnTrackhttpLocationDevice,
        createCallback: (config) => new OwnTrackhttpLocationDevice(config)
      })

      app.post('/api/ownTrack', (req, res) =>
        # find suitable device
        locationDevices = _(@framework.deviceManager.devices).values().filter(
          (device) => device instanceof OwnTrackhttpLocationDevice
        ).value();
        locationDevices.filter(
          (device) => device.config.tid is req.body.tid
        ).forEach( (device) =>
          console.log(req.body);
          device.updateLocation(req.body.lat, req.body.lon)
        )
        res.send([])
      )

  class OwnTrackhttpLocationDevice extends env.devices.Device
    actions:
      updateLocation:
        description: "Updates the location of the Device."
        params:
          lat:
            type: "number"
          lon:
            type: "number"

    constructor: (@config, lastState) ->
      @name = @config.name
      @id = @config.id
      @_linearDistance = lastState?.linearDistance?.value
      @_lat = lastState?.lat?.value
      @_lon = lastState?.lon?.value

      @attributes = {
        linearDistance:
          label: "Linear Distance"
          description: "Linear distance between the devices."
          type: "number"
          unit: "m"
          acronym: 'DIST'
        lat:
          label: "Latitude"
          description: "Location Latitude"
          type: "number"
          decimals: 4
          acronym: 'LAT'
        lon:
          label: "Longitude"
          description: "Location Longitude"
          type: "number"
          decimals: 4
          acronym: 'LON'
      }

      super()

    destroy: () ->
      clearInterval @intervalId if @intervalId?
      super()

    getLinearDistance: -> Promise.resolve(@_linearDistance)
    getLat: -> Promise.resolve(@_lat)
    getLon: -> Promise.resolve(@_lon)

    updateLocation: (lat, lon) ->
      linearDistance = geolib.getDistance(
        {latitude: @config.lat, longitude: @config.lon},
        {latitude: lat, longitude: lon}
      )
      @_linearDistance = linearDistance
      @_lat = lat
      @_lon = lon
      @emit 'linearDistance', @_linearDistance
      @emit 'lat', @_lat
      @emit 'lon', @_lon
      return Promise.resolve()

  # ###Finally
  # Create a instance of my plugin
  pimaticLocation = new PimaticOwntrackHttp
  # and return it to the framework.
  return pimaticLocation
