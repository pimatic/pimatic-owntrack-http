module.exports = {
  title: "pimatic-owntrack-http device config schemas"
  OwnTrackhttpLocationDevice: {
    title: "LocationDevice config options"
    type: "object"
    extensions: ["xAttributeOptions"]
    properties:
      lat:
        description: "Latitude of your home location"
        type: "number"
        required: true
      lon:
        description: "Longitude of your home location"
        type: "number"
        required: true
      tid:
        description: "OwnTrack tid of the device"
        type: "string"
        required: true
  }
}
