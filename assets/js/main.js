window.initMap = () => {
  const map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 37.773972, lng: -122.431297},
    zoom: 8,
    styles: styles,
    streetViewControl: false,
            fullscreenControl: false, 
            mapTypeControlOptions: { 
                mapTypeIds: []
            },
            zoomControlOptions: {
                position: google.maps.ControlPosition.RIGHT_CENTER
            }
  });
}