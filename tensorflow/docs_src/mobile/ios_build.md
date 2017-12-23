# Building TensorFlow on iOS

## Using CocoaPods

The simplest way to get started with TensorFlow on iOS is using the CocoaPods
package management system. You can add the `TensorFlow-experimental` pod to your
Podfile, which installs a universal binary framework. This makes it easy to get
started but has the disadvantage of being hard to customize, which is important
in case you want to shrink your binary size. If you do need the ability to
customize your libraries, see later sections on how to do that.

## Creating your own app

If you'd like to add TensorFlow capabilities to your own app, do the following:

- Create your own app or load your already-created app in XCode.

- Add a file named Podfile at the project root directory with the following content:

        target 'YourProjectName'
        pod 'TensorFlow-experimental'

- Run `pod install` to download and install the `TensorFlow-experimental` pod.

- Open `YourProjectName.xcworkspace` and add your code.

- In your app's **Build Settings**, make sure to add `$(inherited)` to the

While Cocoapods is the quickest and easiest way of getting started, you sometimes
need more flexibility to determine which parts of TensorFlow your app should be
shipped with. For such cases, you can build the iOS libraries from the
sources. [This
guide](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/examples/ios#building-the-tensorflow-ios-libraries-from-source)
contains detailed instructions on how to do that.

