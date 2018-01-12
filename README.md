## Hue Expression

A demo iOS app that uses `ARKit`'s face-tracking capabilities and the Phillip's Hue SDK to recognize your facial expressions and change the color of your Hue lights according to your expression.

## Requirements

In order to run this demo app you will need:
- Xcode 9.2 or above
- An iPhone X
- 1 Phillips Hue Color Ambiance bulb
- The [Phillips Hue iOS app](https://itunes.apple.com/us/app/philips-hue/id1055281310?mt=8)

## Setup

1. Clone this repo
2. Run `pod install`
3. In Xcode, open `ServerController.swift` and replace `hueBridgeIP` with this IP address (see below)
4. In Xcode, open `ServerController.swift` and replace `hueUsername` with your authenticated username (see below)
4. Run the app to your iPhone X

#### Getting Your Bridge's IP

1. Open the Phillip's Hue iOS app
2. Go to Settings>Hue Bridges>Select your Bridge and get the IP Address

#### Getting an Authenticated Hue Username

Note: If you have any trouble with this part, you can find a walkthrough on the [Hue Developer Site.](https://www.developers.meethue.com/documentation/getting-started)

1. Run the following command in terminal (replacing IP_ADDRESS_HERE with the IP address of your Hue bridge)
```
curl -X POST \
  http://<IP_ADDRESS_HERE>/api/ \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{"devicetype":"hue_expressionp#iphone user"}'
```

2. Press the link button on your Hue Bridge
3. Run the above command again
4. Grab the `username` value from the response JSON
