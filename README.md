# Virtual Tourist

A project required by Udacity that serves the purpose of saving a pin to the map through a long press gesture and then click it to see photos taken in that location. The project was approved for the 5th module of the course.

## Getting Started

This is the project of the 5th module in the Udacity iOS Dev Nanodegree to atest our capabilities of using Core Data and dependency injection. Essentials of grand central dispatch was also used to download the images.

The intentionality of the project served to learn how to fetch, save and delete NSManagedObjects and also how to take advantage of threads using GCD to download the images without sacrificing the user experience.
The app is used for the user to mark a location in the map and then see photos of that location in album made with a collection view. The images are being downloaded from Flickr server via their API.

In the `.xcdatamodeld` there are two entities; `image` and `pin`. The relationship is
one **pin** > to many >> **images**.

## UI Details

<img src=Images/VirtualTouristUI.png>

- **Map View**: The user can use a long press gesture to mark a place in the map and then click on the pin to see the images. The “Edit” button is used to delete pins

- **Album**: There is a map view blocked from user interaction in the top of the screen, the map is there to remind the user the location he chose. Beneath the map there is a collection view with all the images that was downloaded, the number of images is locked to 15, but this can be changed in;
`Virtual Tourist/Model/Flickr Client/EndPoints/EndPoints.swift`
`static let numberOfResultsPerPage = 15` 
There is also a button in the bottom of the screen that, when tapped, 15 new images will be dowloaded (different from the ones that where presented first) and the others discarded.
When the user taps a image, this image will be deleted, also, if there are no images for a location an alert will warn the user.

### Prerequisites

Mac OS X 10.14

xCode 10.xx

Valid Flickr API, the key can be updated in; `Virtual Tourist/Model/Flickr Client/EndPoints/EndPoints.swift`
There’s a placeholder for your key in the line 14. `static let api = "API_KEY_GOES_HERE”` 

### Installing

Use **Git Clone** to copy the project:

```

git clone https://github.com/Ardevlp/VirtualTourist.git
cd ../VirtualTourist
open VirtualTourist.xcodeproj

```

## Built With

* [xCode 10.2](https://developer.apple.com/xcode/) 

## License

This project is licensed under the GNU General Public License v3.0 License - see the [LICENSE.md](LICENSE.md) file for details
 
